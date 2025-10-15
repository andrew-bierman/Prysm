import Foundation
import SwiftUI
import SwiftData
import FoundationModels
import Observation

// MARK: - Chat Error Types

enum ChatError: Error, LocalizedError, Sendable {
    case modelUnavailable
    case invalidMessage
    case networkError
    case rateLimitExceeded
    case authenticationFailed
    case invalidConfiguration
    case streamingFailed
    case exportFailed(String)
    case importFailed(String)
    case persistenceFailed(String)
    case toolExecutionFailed(String)
    case cancelled

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            return "Language model is not available"
        case .invalidMessage:
            return "Message content is invalid"
        case .networkError:
            return "Network connection failed"
        case .rateLimitExceeded:
            return "Rate limit exceeded, please try again later"
        case .authenticationFailed:
            return "Authentication failed"
        case .invalidConfiguration:
            return "Invalid model configuration"
        case .streamingFailed:
            return "Streaming response failed"
        case .exportFailed(let reason):
            return "Export failed: \(reason)"
        case .importFailed(let reason):
            return "Import failed: \(reason)"
        case .persistenceFailed(let reason):
            return "Persistence failed: \(reason)"
        case .toolExecutionFailed(let reason):
            return "Tool execution failed: \(reason)"
        case .cancelled:
            return "Operation was cancelled"
        }
    }
}

// MARK: - Chat Settings

struct ChatSettings: Sendable, Codable {
    var temperature: Double = 0.7
    var topP: Double = 0.9
    var maxTokens: Int = 4096
    var systemPrompt: String = "You are Prism, a helpful AI assistant."
    var useCase: String = "general"
    var streamResponses: Bool = true
    var enableTools: Bool = true
    var selectedTools: [String] = []
    var autoSave: Bool = true
    var exportFormat: ExportFormat = .json

    enum ExportFormat: String, CaseIterable, Sendable, Codable {
        case json = "JSON"
        case markdown = "Markdown"
        case plainText = "Plain Text"
        case csv = "CSV"
    }

    var isValid: Bool {
        temperature >= 0.0 && temperature <= 2.0 &&
        topP >= 0.0 && topP <= 1.0 &&
        maxTokens > 0 && maxTokens <= 32768 &&
        !systemPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Conversation Export/Import Models

struct ConversationExport: Sendable, Codable {
    let id: UUID
    let title: String
    let createdAt: Date
    let lastModified: Date
    let messageCount: Int
    let settings: ChatSettings
    let messages: [ExportMessage]
    let metadata: [String: String]

    struct ExportMessage: Sendable, Codable {
        let id: UUID
        let content: String
        let role: String
        let timestamp: Date
        let tokens: Int?
    }
}

// MARK: - Chat View Model

@MainActor
@Observable
final class ChatViewModel: Sendable {

    // MARK: - Properties

    // Core state
    private(set) var messages: [Message] = []
    private(set) var isResponding: Bool = false
    private(set) var currentError: ChatError?
    private(set) var isModelAvailable: Bool = false

    // Settings
    var settings: ChatSettings = ChatSettings()

    // Private properties
    private var modelContext: ModelContext?
    private var languageModel: SystemLanguageModel?
    private var currentTask: Task<Void, Error>?
    private var streamingTask: Task<Void, Never>?
    private let toolCollection = CustomToolCollection.allTools

    // Performance tracking
    private(set) var responseTime: TimeInterval = 0
    private(set) var tokenUsage: Int = 0
    private(set) var conversationId: UUID = UUID()

    // MARK: - Initialization

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        Task {
            await initializeModel()
            await loadPersistedSettings()
        }
    }

    // MARK: - Model Management

    nonisolated private func initializeModel() async {
        do {
            let model = try await SystemLanguageModel()
            let available = await model.supportsCapability(.completion)

            await MainActor.run {
                self.languageModel = model
                self.isModelAvailable = available
            }
        } catch {
            await MainActor.run {
                self.currentError = .modelUnavailable
                self.isModelAvailable = false
            }
        }
    }

    func checkModelAvailability() async {
        await initializeModel()
    }

    // MARK: - Message Management

    func sendMessage(_ content: String) async {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            currentError = .invalidMessage
            return
        }

        guard isModelAvailable, let model = languageModel else {
            currentError = .modelUnavailable
            return
        }

        // Cancel any existing task
        currentTask?.cancel()
        streamingTask?.cancel()

        clearError()

        let userMessage = Message(content: content, role: .user)
        await addMessage(userMessage)

        isResponding = true
        let startTime = Date()

        currentTask = Task {
            do {
                if settings.streamResponses {
                    await handleStreamingResponse(model: model, userMessage: userMessage)
                } else {
                    await handleRegularResponse(model: model, userMessage: userMessage)
                }

                responseTime = Date().timeIntervalSince(startTime)

                if settings.autoSave {
                    await saveConversation()
                }
            } catch {
                if !Task.isCancelled {
                    await MainActor.run {
                        self.currentError = error as? ChatError ?? .networkError
                    }
                }
            }

            await MainActor.run {
                self.isResponding = false
            }
        }
    }

    private func handleRegularResponse(model: SystemLanguageModel, userMessage: Message) async {
        do {
            let request = try await createLanguageModelRequest()
            let response = try await model.generate(request: request)

            let assistantMessage = Message(
                content: response.content,
                role: .assistant,
                tokens: response.usage?.outputTokens
            )

            await addMessage(assistantMessage)

            if let usage = response.usage {
                await MainActor.run {
                    self.tokenUsage += (usage.inputTokens ?? 0) + (usage.outputTokens ?? 0)
                }
            }
        } catch {
            throw error as? ChatError ?? .networkError
        }
    }

    private func handleStreamingResponse(model: SystemLanguageModel, userMessage: Message) async {
        do {
            let request = try await createLanguageModelRequest()
            let assistantMessage = Message(content: "", role: .assistant)
            await addMessage(assistantMessage)

            streamingTask = Task {
                var accumulatedContent = ""

                for try await chunk in model.generateStreaming(request: request) {
                    if Task.isCancelled { break }

                    accumulatedContent += chunk.content

                    await MainActor.run {
                        if let lastMessageIndex = self.messages.lastIndex(where: { $0.role == .assistant }) {
                            self.messages[lastMessageIndex].content = accumulatedContent
                        }
                    }
                }

                // Update final message with complete content
                await MainActor.run {
                    if let lastMessageIndex = self.messages.lastIndex(where: { $0.role == .assistant }) {
                        self.messages[lastMessageIndex].content = accumulatedContent
                    }
                }
            }

            await streamingTask?.value
        } catch {
            throw ChatError.streamingFailed
        }
    }

    private func createLanguageModelRequest() async throws -> LanguageModel.Request {
        let conversationMessages = messages.map { message in
            LanguageModel.Message(role: message.role.languageModelRole, content: message.content)
        }

        // Add system message if provided
        var allMessages = conversationMessages
        if !settings.systemPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let systemMessage = LanguageModel.Message(role: .system, content: settings.systemPrompt)
            allMessages.insert(systemMessage, at: 0)
        }

        var request = LanguageModel.Request(messages: allMessages)

        // Configure generation parameters
        request.temperature = settings.temperature
        request.topP = settings.topP
        request.maxTokens = settings.maxTokens

        // Add tools if enabled
        if settings.enableTools && !settings.selectedTools.isEmpty {
            let enabledTools = toolCollection.filter { tool in
                settings.selectedTools.contains(tool.name)
            }
            request.tools = enabledTools
        }

        return request
    }

    private func addMessage(_ message: Message) async {
        await MainActor.run {
            self.messages.append(message)
        }

        // Persist to SwiftData if available
        if let context = modelContext {
            context.insert(message)
            try? context.save()
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

    func editMessage(at index: Int, newContent: String) {
        guard index >= 0 && index < messages.count else { return }
        guard !newContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        messages[index].content = newContent

        // Update in SwiftData if available
        if let context = modelContext {
            try? context.save()
        }
    }

    // MARK: - Conversation Management

    func clearSession() async {
        // Cancel any ongoing operations
        currentTask?.cancel()
        streamingTask?.cancel()

        await MainActor.run {
            self.messages.removeAll()
            self.currentError = nil
            self.isResponding = false
            self.responseTime = 0
            self.tokenUsage = 0
            self.conversationId = UUID()
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

    func retryLastMessage() async {
        guard let lastUserMessage = messages.last(where: { $0.role == .user }) else { return }

        // Remove any assistant messages after the last user message
        let userMessageIndex = messages.lastIndex { $0.id == lastUserMessage.id } ?? messages.count
        messages = Array(messages.prefix(through: userMessageIndex))

        await sendMessage(lastUserMessage.content)
    }

    // MARK: - Settings Management

    func updateSettings(_ newSettings: ChatSettings) {
        guard newSettings.isValid else {
            currentError = .invalidConfiguration
            return
        }

        settings = newSettings
        Task {
            await saveSettings()
        }
    }

    private func loadPersistedSettings() async {
        // Load settings from UserDefaults or other persistence layer
        if let data = UserDefaults.standard.data(forKey: "ChatSettings"),
           let loadedSettings = try? JSONDecoder().decode(ChatSettings.self, from: data) {
            await MainActor.run {
                self.settings = loadedSettings
            }
        }
    }

    private func saveSettings() async {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: "ChatSettings")
        }
    }

    // MARK: - Export/Import Functionality

    func exportConversation(format: ChatSettings.ExportFormat = .json) async throws -> Data {
        let export = ConversationExport(
            id: conversationId,
            title: generateConversationTitle(),
            createdAt: messages.first?.timestamp ?? Date(),
            lastModified: messages.last?.timestamp ?? Date(),
            messageCount: messages.count,
            settings: settings,
            messages: messages.map { message in
                ConversationExport.ExportMessage(
                    id: message.id,
                    content: message.content,
                    role: message.role.rawValue,
                    timestamp: message.timestamp,
                    tokens: message.tokens
                )
            },
            metadata: [
                "responseTime": String(responseTime),
                "tokenUsage": String(tokenUsage),
                "exportedAt": ISO8601DateFormatter().string(from: Date())
            ]
        )

        switch format {
        case .json:
            return try JSONEncoder().encode(export)
        case .markdown:
            return try exportToMarkdown(export).data(using: .utf8) ?? Data()
        case .plainText:
            return try exportToPlainText(export).data(using: .utf8) ?? Data()
        case .csv:
            return try exportToCSV(export).data(using: .utf8) ?? Data()
        }
    }

    private func exportToMarkdown(_ export: ConversationExport) throws -> String {
        var markdown = "# \(export.title)\n\n"
        markdown += "**Created:** \(DateFormatter.localizedString(from: export.createdAt, dateStyle: .medium, timeStyle: .short))\n"
        markdown += "**Messages:** \(export.messageCount)\n"
        markdown += "**Tokens Used:** \(tokenUsage)\n\n"
        markdown += "---\n\n"

        for message in export.messages {
            markdown += "## \(message.role.capitalized)\n"
            markdown += "*\(DateFormatter.localizedString(from: message.timestamp, dateStyle: .none, timeStyle: .short))*\n\n"
            markdown += "\(message.content)\n\n"
        }

        return markdown
    }

    private func exportToPlainText(_ export: ConversationExport) throws -> String {
        var text = "\(export.title)\n"
        text += String(repeating: "=", count: export.title.count) + "\n\n"

        for message in export.messages {
            text += "\(message.role.uppercased()): \(message.content)\n\n"
        }

        return text
    }

    private func exportToCSV(_ export: ConversationExport) throws -> String {
        var csv = "Timestamp,Role,Content,Tokens\n"

        for message in export.messages {
            let timestamp = ISO8601DateFormatter().string(from: message.timestamp)
            let content = message.content.replacingOccurrences(of: "\"", with: "\"\"")
            let tokens = message.tokens.map(String.init) ?? ""
            csv += "\"\(timestamp)\",\"\(message.role)\",\"\(content)\",\"\(tokens)\"\n"
        }

        return csv
    }

    func importConversation(from data: Data) async throws {
        do {
            let export = try JSONDecoder().decode(ConversationExport.self, from: data)

            await clearSession()

            // Import messages
            for exportMessage in export.messages {
                let message = Message(
                    content: exportMessage.content,
                    role: MessageRole(rawValue: exportMessage.role) ?? .user,
                    timestamp: exportMessage.timestamp,
                    tokens: exportMessage.tokens
                )
                await addMessage(message)
            }

            // Import settings
            await MainActor.run {
                self.settings = export.settings
                self.conversationId = export.id
            }

            await saveSettings()

        } catch {
            throw ChatError.importFailed(error.localizedDescription)
        }
    }

    // MARK: - Structured Output Generation

    func generateStructuredOutput<T: Generable>(type: T.Type, prompt: String) async throws -> T {
        guard isModelAvailable, let model = languageModel else {
            throw ChatError.modelUnavailable
        }

        let request = LanguageModel.Request(
            messages: [
                LanguageModel.Message(role: .system, content: settings.systemPrompt),
                LanguageModel.Message(role: .user, content: prompt)
            ],
            generable: type
        )

        let response = try await model.generate(request: request)

        guard let structuredOutput = response.generable as? T else {
            throw ChatError.invalidConfiguration
        }

        return structuredOutput
    }

    // MARK: - Tool Management

    func getAvailableTools() -> [any Tool] {
        return toolCollection
    }

    func enableTool(_ toolName: String) {
        if !settings.selectedTools.contains(toolName) {
            settings.selectedTools.append(toolName)
            Task { await saveSettings() }
        }
    }

    func disableTool(_ toolName: String) {
        settings.selectedTools.removeAll { $0 == toolName }
        Task { await saveSettings() }
    }

    // MARK: - Persistence

    private func saveConversation() async {
        guard let context = modelContext else { return }

        do {
            try context.save()
        } catch {
            await MainActor.run {
                self.currentError = .persistenceFailed(error.localizedDescription)
            }
        }
    }

    func loadConversation(with id: UUID) async throws {
        guard let context = modelContext else {
            throw ChatError.persistenceFailed("No model context available")
        }

        let fetchDescriptor = FetchDescriptor<Message>(
            predicate: #Predicate { _ in true }, // Load all messages for now
            sortBy: [SortDescriptor(\.timestamp)]
        )

        do {
            let loadedMessages = try context.fetch(fetchDescriptor)
            await MainActor.run {
                self.messages = loadedMessages
                self.conversationId = id
            }
        } catch {
            throw ChatError.persistenceFailed(error.localizedDescription)
        }
    }

    // MARK: - Error Handling

    func clearError() {
        currentError = nil
    }

    func handleError(_ error: Error) {
        if let chatError = error as? ChatError {
            currentError = chatError
        } else {
            currentError = .networkError
        }
    }

    // MARK: - Utility Methods

    func cancelCurrentOperation() {
        currentTask?.cancel()
        streamingTask?.cancel()
        isResponding = false
    }

    private func generateConversationTitle() -> String {
        if let firstUserMessage = messages.first(where: { $0.role == .user }) {
            let content = firstUserMessage.content
            let words = content.components(separatedBy: .whitespacesAndNewlines)
            let title = words.prefix(5).joined(separator: " ")
            return title.isEmpty ? "New Conversation" : title
        }
        return "New Conversation"
    }

    func getConversationStats() -> (messageCount: Int, tokenUsage: Int, responseTime: TimeInterval) {
        return (messages.count, tokenUsage, responseTime)
    }

    // MARK: - Memory Management

    func cleanup() {
        currentTask?.cancel()
        streamingTask?.cancel()
        currentTask = nil
        streamingTask = nil
        languageModel = nil
    }

    deinit {
        cleanup()
    }
}

// MARK: - Extensions

extension ChatViewModel {
    var hasMessages: Bool {
        !messages.isEmpty
    }

    var canSendMessage: Bool {
        !isResponding && isModelAvailable
    }

    var lastMessage: Message? {
        messages.last
    }

    var conversationTitle: String {
        generateConversationTitle()
    }
}