import Foundation
import SwiftData
import FoundationModels

@Model
final class Message: Sendable {
    let id: UUID
    var content: String
    var role: MessageRole
    var timestamp: Date
    var tokens: Int?

    init(content: String, role: MessageRole, timestamp: Date = Date(), tokens: Int? = nil) {
        self.id = UUID()
        self.content = content
        self.role = role
        self.timestamp = timestamp
        self.tokens = tokens
    }
}

enum MessageRole: String, Codable, CaseIterable, Sendable {
    case user
    case assistant
    case system

    var displayName: String {
        switch self {
        case .user: return "You"
        case .assistant: return "Prism"
        case .system: return "System"
        }
    }

    var iconName: String {
        switch self {
        case .user: return "person.circle.fill"
        case .assistant: return "sparkles"
        case .system: return "gearshape.fill"
        }
    }

    var languageModelRole: LanguageModel.MessageRole {
        switch self {
        case .user: return .user
        case .assistant: return .assistant
        case .system: return .system
        }
    }
}