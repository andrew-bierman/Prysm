import Foundation

// MARK: - LLMMessage

struct LLMMessage: Identifiable, Equatable {
    enum Role: String, Codable {
        case system
        case user
        case assistant
    }

    let id: UUID
    let role: Role
    let content: String
    let timestamp: Date

    init(role: Role, content: String) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
    }
}

// MARK: - GenerationConfig

struct GenerationConfig {
    var temperature: Double = 0.7
    var topP: Double = 0.95
    var maxTokens: Int = 2048
    var stream: Bool = true
}

// MARK: - LLMProvider

@MainActor
protocol LLMProvider {
    func sendMessage(
        _ content: String,
        history: [LLMMessage],
        systemPrompt: String,
        config: GenerationConfig
    ) -> AsyncThrowingStream<String, Error>

    var displayName: String { get }
    var isAvailable: Bool { get }
}
