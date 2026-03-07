import Foundation

// MARK: - RemoteProviderError

enum RemoteProviderError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, body: String)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The configured base URL is invalid."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .httpError(let statusCode, let body):
            return "HTTP error \(statusCode): \(body)"
        case .decodingError:
            return "Failed to decode the server response."
        }
    }
}

// MARK: - RemoteProviderConfig

struct RemoteProviderConfig: Codable, Equatable, Sendable {
    var baseURL: String = "http://localhost:1234"
    var apiKey: String = ""
    var modelName: String = "default"
    var organizationID: String = ""

    var chatCompletionsURL: URL? {
        let trimmed = baseURL.trimmingCharacters(in: .whitespaces)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return URL(string: "\(trimmed)/v1/chat/completions")
    }
}

// MARK: - RemoteProvider

@Observable
@MainActor
final class RemoteProvider: LLMProvider {
    var config: RemoteProviderConfig
    private let urlSession: URLSession

    var displayName: String {
        "Remote: \(config.modelName)"
    }

    var isAvailable: Bool {
        config.chatCompletionsURL != nil
            && !config.baseURL.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(config: RemoteProviderConfig) {
        self.config = config
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 120
        self.urlSession = URLSession(configuration: sessionConfig)
    }

    func sendMessage(
        _ content: String,
        history: [LLMMessage],
        systemPrompt: String,
        config: GenerationConfig
    ) -> AsyncThrowingStream<String, Error> {
        let providerConfig = self.config
        let session = self.urlSession
        let completionsURL = providerConfig.chatCompletionsURL

        return AsyncThrowingStream { continuation in
            let task = Task.detached {
                guard let url = completionsURL else {
                    continuation.finish(throwing: RemoteProviderError.invalidURL)
                    return
                }

                // Build messages array
                var messages: [[String: String]] = []

                if !systemPrompt.isEmpty {
                    messages.append(["role": "system", "content": systemPrompt])
                }

                for message in history {
                    messages.append([
                        "role": message.role.rawValue,
                        "content": message.content
                    ])
                }

                messages.append(["role": "user", "content": content])

                // Build request body
                let body: [String: Any] = [
                    "model": providerConfig.modelName,
                    "messages": messages,
                    "temperature": config.temperature,
                    "top_p": config.topP,
                    "max_tokens": config.maxTokens,
                    "stream": config.stream
                ]

                // Serialize
                guard let httpBody = try? JSONSerialization.data(
                    withJSONObject: body
                ) else {
                    continuation.finish(throwing: RemoteProviderError.decodingError)
                    return
                }

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = httpBody
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                if !providerConfig.apiKey.isEmpty {
                    request.setValue(
                        "Bearer \(providerConfig.apiKey)",
                        forHTTPHeaderField: "Authorization"
                    )
                }

                if !providerConfig.organizationID.isEmpty {
                    request.setValue(
                        providerConfig.organizationID,
                        forHTTPHeaderField: "OpenAI-Organization"
                    )
                }

                do {
                    if config.stream {
                        try await Self.handleStreaming(
                            session: session,
                            request: request,
                            continuation: continuation
                        )
                    } else {
                        try await Self.handleNonStreaming(
                            session: session,
                            request: request,
                            continuation: continuation
                        )
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    // MARK: - Streaming

    private static func handleStreaming(
        session: URLSession,
        request: URLRequest,
        continuation: AsyncThrowingStream<String, Error>.Continuation
    ) async throws {
        let (bytes, response) = try await session.bytes(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw RemoteProviderError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            // Attempt to collect error body
            var errorBody = ""
            for try await line in bytes.lines {
                errorBody += line
            }
            throw RemoteProviderError.httpError(
                statusCode: httpResponse.statusCode,
                body: errorBody
            )
        }

        for try await line in bytes.lines {
            if Task.isCancelled { break }

            guard line.hasPrefix("data: ") else { continue }

            let data = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)

            if data == "[DONE]" {
                break
            }

            guard let jsonData = data.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let delta = firstChoice["delta"] as? [String: Any],
                  let content = delta["content"] as? String
            else {
                continue
            }

            continuation.yield(content)
        }

        continuation.finish()
    }

    // MARK: - Non-Streaming

    private static func handleNonStreaming(
        session: URLSession,
        request: URLRequest,
        continuation: AsyncThrowingStream<String, Error>.Continuation
    ) async throws {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw RemoteProviderError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw RemoteProviderError.httpError(
                statusCode: httpResponse.statusCode,
                body: body
            )
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String
        else {
            throw RemoteProviderError.decodingError
        }

        continuation.yield(content)
        continuation.finish()
    }
}
