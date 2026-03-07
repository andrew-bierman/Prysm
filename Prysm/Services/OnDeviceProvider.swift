import Foundation
import FoundationModels

@Observable
final class OnDeviceProvider: LLMProvider {
    private var session: LanguageModelSession
    private var currentSystemPrompt: String

    var displayName: String { "On-Device Model" }

    var isAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }

    init(systemPrompt: String = AppConfig.assistantInstructions) {
        self.currentSystemPrompt = systemPrompt
        self.session = LanguageModelSession(
            instructions: Instructions(systemPrompt)
        )
    }

    func sendMessage(
        _ content: String,
        history: [LLMMessage],
        systemPrompt: String,
        config: GenerationConfig
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task { @MainActor in
                do {
                    // Only recreate session if the system prompt changed
                    if systemPrompt != self.currentSystemPrompt {
                        self.currentSystemPrompt = systemPrompt
                        self.session = LanguageModelSession(
                            instructions: Instructions(systemPrompt)
                        )

                        // Replay history into the new session so context is not lost
                        for message in history where message.role == .user || message.role == .assistant {
                            if message.role == .user {
                                let _ = try await self.session.respond(to: Prompt(message.content))
                            }
                        }
                    }

                    let responseStream = self.session.streamResponse(to: Prompt(content))
                    var fullText = ""

                    for try await _ in responseStream {
                        if let lastEntry = self.session.transcript.last,
                           case .response(let response) = lastEntry {
                            let currentText = response.segments.compactMap { segment in
                                if case .text(let textSegment) = segment {
                                    return textSegment.content
                                }
                                return nil
                            }.joined(separator: " ")

                            if currentText != fullText {
                                let delta = String(currentText.dropFirst(fullText.count))
                                fullText = currentText
                                continuation.yield(delta)
                            }
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    func resetSession(systemPrompt: String) {
        self.currentSystemPrompt = systemPrompt
        session = LanguageModelSession(
            instructions: Instructions(systemPrompt)
        )
    }
}
