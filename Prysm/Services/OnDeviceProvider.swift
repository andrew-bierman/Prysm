import Foundation
import FoundationModels

@Observable
final class OnDeviceProvider: LLMProvider {
    private var session: LanguageModelSession

    var displayName: String { "On-Device Model" }

    var isAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }

    init(systemPrompt: String = AppConfig.assistantInstructions) {
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
                    // Recreate session with current system prompt
                    self.session = LanguageModelSession(
                        instructions: Instructions(systemPrompt)
                    )

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
        session = LanguageModelSession(
            instructions: Instructions(systemPrompt)
        )
    }
}
