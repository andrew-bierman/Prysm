import Foundation
import SwiftData
import Observation

@Observable
final class SimpleChatViewModel {
    var messages: [Message] = []
    var isResponding: Bool = false
    var currentError: String?
    var isModelAvailable: Bool = true

    private var modelContext: ModelContext?

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        loadMessages()
    }

    // MARK: - Public Methods

    func sendMessage(_ content: String) async {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            currentError = "Message content cannot be empty"
            return
        }

        clearError()

        let userMessage = Message(content: content, role: .user)
        await addMessage(userMessage)

        await MainActor.run {
            isResponding = true
        }

        // Simulate AI response delay
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        if !Task.isCancelled {
            let responses = [
                "Thank you for your message: '\(content)'. I'm here to help you with any questions you may have.",
                "That's an interesting point about '\(content)'. Let me think about that and provide you with a helpful response.",
                "I understand you're asking about '\(content)'. Based on my knowledge, I can help you with that topic.",
                "Great question regarding '\(content)'! I'd be happy to assist you with more information.",
                "I appreciate you sharing '\(content)' with me. Let me provide you with a comprehensive response."
            ]

            let responseContent = responses.randomElement() ?? "I'm here to help!"
            let assistantMessage = Message(content: responseContent, role: .assistant)
            await addMessage(assistantMessage)
        }

        await MainActor.run {
            isResponding = false
        }
    }

    func clearSession() async {
        await MainActor.run {
            messages.removeAll()
            currentError = nil
            isResponding = false
        }

        // Clear from SwiftData if available
        if let context = modelContext {
            let fetchDescriptor = FetchDescriptor<Message>()
            if let allMessages = try? context.fetch(fetchDescriptor) {
                for message in allMessages {
                    context.delete(message)
                }
                try? context.save()
            }
        }
    }

    func deleteMessage(at index: Int) {
        guard index >= 0 && index < messages.count else { return }

        let message = messages[index]
        messages.remove(at: index)

        // Remove from SwiftData if available
        if let context = modelContext {
            context.delete(message)
            try? context.save()
        }
    }

    func cancelCurrentOperation() {
        isResponding = false
    }

    func clearError() {
        currentError = nil
    }

    func exportConversation(format: ExportFormat = .plainText) async throws -> Data {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        let exportText = messages.map { message in
            "\(message.role.displayName) (\(dateFormatter.string(from: message.timestamp))):\n\(message.content)\n"
        }.joined(separator: "\n")

        guard let data = exportText.data(using: .utf8) else {
            throw ExportError.encodingFailed
        }

        return data
    }

    // MARK: - Private Methods

    private func loadMessages() {
        guard let modelContext = modelContext else { return }

        let descriptor = FetchDescriptor<Message>(
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )

        do {
            messages = try modelContext.fetch(descriptor)
        } catch {
            currentError = "Failed to load messages: \(error.localizedDescription)"
        }
    }

    private func addMessage(_ message: Message) async {
        await MainActor.run {
            messages.append(message)
        }

        // Persist to SwiftData if available
        if let context = modelContext {
            context.insert(message)
            try? context.save()
        }
    }
}

// MARK: - Extensions

extension SimpleChatViewModel {
    var hasMessages: Bool {
        !messages.isEmpty
    }

    var canSendMessage: Bool {
        !isResponding && isModelAvailable
    }

    var lastMessage: Message? {
        messages.last
    }
}

// MARK: - Supporting Types

enum ExportFormat {
    case plainText
    case json
    case markdown
}

enum ExportError: Error, LocalizedError {
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode export data"
        }
    }
}