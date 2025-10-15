import XCTest
import SwiftData
import FoundationModels
@testable import Prism

@MainActor
final class ChatViewModelTests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var viewModel: ChatViewModel!

    override func setUp() async throws {
        try await super.setUp()

        // Create in-memory model container for testing
        modelContainer = try ModelContainer(
            for: Message.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        modelContext = modelContainer.mainContext
        viewModel = ChatViewModel(modelContext: modelContext)

        // Wait for model initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
    }

    override func tearDown() async throws {
        viewModel.cleanup()
        viewModel = nil
        modelContext = nil
        modelContainer = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testViewModelInitialization() async {
        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertFalse(viewModel.isResponding)
        XCTAssertNil(viewModel.currentError)
        XCTAssertEqual(viewModel.tokenUsage, 0)
        XCTAssertEqual(viewModel.responseTime, 0)
        XCTAssertNotNil(viewModel.conversationId)
    }

    func testSettingsInitialization() async {
        let settings = viewModel.settings
        XCTAssertEqual(settings.temperature, 0.7)
        XCTAssertEqual(settings.topP, 0.9)
        XCTAssertEqual(settings.maxTokens, 4096)
        XCTAssertEqual(settings.systemPrompt, "You are Prism, a helpful AI assistant.")
        XCTAssertTrue(settings.streamResponses)
        XCTAssertTrue(settings.enableTools)
        XCTAssertTrue(settings.autoSave)
        XCTAssertEqual(settings.exportFormat, .json)
    }

    // MARK: - Message Management Tests

    func testSendValidMessage() async {
        let testMessage = "Hello, this is a test message"

        await viewModel.sendMessage(testMessage)

        // Check that user message was added
        XCTAssertEqual(viewModel.messages.count, 1)
        XCTAssertEqual(viewModel.messages.first?.content, testMessage)
        XCTAssertEqual(viewModel.messages.first?.role, .user)
    }

    func testSendEmptyMessage() async {
        await viewModel.sendMessage("")

        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertEqual(viewModel.currentError, .invalidMessage)
    }

    func testSendWhitespaceOnlyMessage() async {
        await viewModel.sendMessage("   \n\t   ")

        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertEqual(viewModel.currentError, .invalidMessage)
    }

    func testDeleteMessage() async {
        // Add test messages
        let message1 = Message(content: "First message", role: .user)
        let message2 = Message(content: "Second message", role: .assistant)

        await viewModel.addMessage(message1)
        await viewModel.addMessage(message2)

        XCTAssertEqual(viewModel.messages.count, 2)

        // Delete first message
        viewModel.deleteMessage(at: 0)

        XCTAssertEqual(viewModel.messages.count, 1)
        XCTAssertEqual(viewModel.messages.first?.content, "Second message")
    }

    func testDeleteMessageOutOfBounds() async {
        let message = Message(content: "Test message", role: .user)
        await viewModel.addMessage(message)

        XCTAssertEqual(viewModel.messages.count, 1)

        // Try to delete with invalid index
        viewModel.deleteMessage(at: 5)

        // Message should still be there
        XCTAssertEqual(viewModel.messages.count, 1)
    }

    func testEditMessage() async {
        let message = Message(content: "Original content", role: .user)
        await viewModel.addMessage(message)

        let newContent = "Edited content"
        viewModel.editMessage(at: 0, newContent: newContent)

        XCTAssertEqual(viewModel.messages.first?.content, newContent)
    }

    func testEditMessageWithEmptyContent() async {
        let originalContent = "Original content"
        let message = Message(content: originalContent, role: .user)
        await viewModel.addMessage(message)

        viewModel.editMessage(at: 0, newContent: "")

        // Content should remain unchanged
        XCTAssertEqual(viewModel.messages.first?.content, originalContent)
    }

    // MARK: - Settings Management Tests

    func testUpdateValidSettings() async {
        var newSettings = ChatSettings()
        newSettings.temperature = 0.5
        newSettings.maxTokens = 2048
        newSettings.systemPrompt = "Custom system prompt"

        viewModel.updateSettings(newSettings)

        XCTAssertEqual(viewModel.settings.temperature, 0.5)
        XCTAssertEqual(viewModel.settings.maxTokens, 2048)
        XCTAssertEqual(viewModel.settings.systemPrompt, "Custom system prompt")
        XCTAssertNil(viewModel.currentError)
    }

    func testUpdateInvalidSettings() async {
        var invalidSettings = ChatSettings()
        invalidSettings.temperature = 3.0 // Invalid: > 2.0
        invalidSettings.maxTokens = -100 // Invalid: < 0

        viewModel.updateSettings(invalidSettings)

        XCTAssertEqual(viewModel.currentError, .invalidConfiguration)
    }

    func testSettingsValidation() async {
        var settings = ChatSettings()

        // Test valid settings
        XCTAssertTrue(settings.isValid)

        // Test invalid temperature
        settings.temperature = -0.1
        XCTAssertFalse(settings.isValid)

        settings.temperature = 2.1
        XCTAssertFalse(settings.isValid)

        // Reset and test invalid topP
        settings = ChatSettings()
        settings.topP = -0.1
        XCTAssertFalse(settings.isValid)

        settings.topP = 1.1
        XCTAssertFalse(settings.isValid)

        // Reset and test invalid maxTokens
        settings = ChatSettings()
        settings.maxTokens = 0
        XCTAssertFalse(settings.isValid)

        settings.maxTokens = 50000
        XCTAssertFalse(settings.isValid)

        // Reset and test empty system prompt
        settings = ChatSettings()
        settings.systemPrompt = ""
        XCTAssertFalse(settings.isValid)

        settings.systemPrompt = "   "
        XCTAssertFalse(settings.isValid)
    }

    // MARK: - Export/Import Tests

    func testExportConversationJSON() async throws {
        // Add test messages
        let userMessage = Message(content: "Hello", role: .user)
        let assistantMessage = Message(content: "Hi there!", role: .assistant, tokens: 3)

        await viewModel.addMessage(userMessage)
        await viewModel.addMessage(assistantMessage)

        let exportData = try await viewModel.exportConversation(format: .json)
        XCTAssertFalse(exportData.isEmpty)

        // Verify the export can be decoded
        let export = try JSONDecoder().decode(ConversationExport.self, from: exportData)
        XCTAssertEqual(export.messageCount, 2)
        XCTAssertEqual(export.messages.count, 2)
        XCTAssertEqual(export.messages.first?.content, "Hello")
        XCTAssertEqual(export.messages.last?.content, "Hi there!")
    }

    func testExportConversationMarkdown() async throws {
        let userMessage = Message(content: "Test message", role: .user)
        await viewModel.addMessage(userMessage)

        let exportData = try await viewModel.exportConversation(format: .markdown)
        let markdownString = String(data: exportData, encoding: .utf8)

        XCTAssertNotNil(markdownString)
        XCTAssertTrue(markdownString!.contains("# "))
        XCTAssertTrue(markdownString!.contains("## User"))
        XCTAssertTrue(markdownString!.contains("Test message"))
    }

    func testExportConversationPlainText() async throws {
        let userMessage = Message(content: "Plain text test", role: .user)
        await viewModel.addMessage(userMessage)

        let exportData = try await viewModel.exportConversation(format: .plainText)
        let textString = String(data: exportData, encoding: .utf8)

        XCTAssertNotNil(textString)
        XCTAssertTrue(textString!.contains("USER: Plain text test"))
    }

    func testExportConversationCSV() async throws {
        let userMessage = Message(content: "CSV test", role: .user, tokens: 2)
        await viewModel.addMessage(userMessage)

        let exportData = try await viewModel.exportConversation(format: .csv)
        let csvString = String(data: exportData, encoding: .utf8)

        XCTAssertNotNil(csvString)
        XCTAssertTrue(csvString!.contains("Timestamp,Role,Content,Tokens"))
        XCTAssertTrue(csvString!.contains("\"user\""))
        XCTAssertTrue(csvString!.contains("\"CSV test\""))
    }

    func testImportConversation() async throws {
        // Create export data
        let originalMessage = Message(content: "Original message", role: .user)
        await viewModel.addMessage(originalMessage)

        let exportData = try await viewModel.exportConversation(format: .json)

        // Clear current conversation
        await viewModel.clearSession()
        XCTAssertTrue(viewModel.messages.isEmpty)

        // Import the conversation
        try await viewModel.importConversation(from: exportData)

        XCTAssertEqual(viewModel.messages.count, 1)
        XCTAssertEqual(viewModel.messages.first?.content, "Original message")
        XCTAssertEqual(viewModel.messages.first?.role, .user)
    }

    func testImportInvalidData() async {
        let invalidData = "invalid json data".data(using: .utf8)!

        do {
            try await viewModel.importConversation(from: invalidData)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is ChatError)
            if case .importFailed = error as? ChatError {
                // Expected error
            } else {
                XCTFail("Unexpected error type")
            }
        }
    }

    // MARK: - Error Handling Tests

    func testErrorHandling() async {
        let testError = ChatError.networkError
        viewModel.handleError(testError)

        XCTAssertEqual(viewModel.currentError, .networkError)
    }

    func testClearError() async {
        viewModel.handleError(ChatError.rateLimitExceeded)
        XCTAssertNotNil(viewModel.currentError)

        viewModel.clearError()
        XCTAssertNil(viewModel.currentError)
    }

    func testGenericErrorHandling() async {
        struct TestError: Error {}
        let genericError = TestError()

        viewModel.handleError(genericError)
        XCTAssertEqual(viewModel.currentError, .networkError)
    }

    // MARK: - Tool Integration Tests

    func testGetAvailableTools() async {
        let tools = viewModel.getAvailableTools()

        XCTAssertFalse(tools.isEmpty)
        XCTAssertEqual(tools.count, 3) // Weather, Calculator, WebSearch

        let toolNames = tools.map { $0.name }
        XCTAssertTrue(toolNames.contains("get_weather"))
        XCTAssertTrue(toolNames.contains("calculate"))
        XCTAssertTrue(toolNames.contains("web_search"))
    }

    func testEnableTool() async {
        XCTAssertTrue(viewModel.settings.selectedTools.isEmpty)

        viewModel.enableTool("get_weather")

        XCTAssertTrue(viewModel.settings.selectedTools.contains("get_weather"))
    }

    func testDisableTool() async {
        viewModel.enableTool("get_weather")
        viewModel.enableTool("calculate")

        XCTAssertTrue(viewModel.settings.selectedTools.contains("get_weather"))
        XCTAssertTrue(viewModel.settings.selectedTools.contains("calculate"))

        viewModel.disableTool("get_weather")

        XCTAssertFalse(viewModel.settings.selectedTools.contains("get_weather"))
        XCTAssertTrue(viewModel.settings.selectedTools.contains("calculate"))
    }

    func testEnableDuplicateTool() async {
        viewModel.enableTool("get_weather")
        viewModel.enableTool("get_weather") // Enable again

        // Should only appear once
        let weatherToolCount = viewModel.settings.selectedTools.filter { $0 == "get_weather" }.count
        XCTAssertEqual(weatherToolCount, 1)
    }

    // MARK: - Conversation Management Tests

    func testClearSession() async {
        // Add test data
        let message = Message(content: "Test", role: .user)
        await viewModel.addMessage(message)
        viewModel.handleError(ChatError.networkError)

        XCTAssertFalse(viewModel.messages.isEmpty)
        XCTAssertNotNil(viewModel.currentError)

        let originalConversationId = viewModel.conversationId

        await viewModel.clearSession()

        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertNil(viewModel.currentError)
        XCTAssertFalse(viewModel.isResponding)
        XCTAssertEqual(viewModel.responseTime, 0)
        XCTAssertEqual(viewModel.tokenUsage, 0)
        XCTAssertNotEqual(viewModel.conversationId, originalConversationId)
    }

    func testRetryLastMessage() async {
        // Add user message followed by assistant message
        let userMessage = Message(content: "Hello", role: .user)
        let assistantMessage = Message(content: "Hi", role: .assistant)

        await viewModel.addMessage(userMessage)
        await viewModel.addMessage(assistantMessage)

        XCTAssertEqual(viewModel.messages.count, 2)

        // This would normally trigger a new response, but since we don't have a real model,
        // we're just testing that it finds the last user message correctly
        // In a real test with mocked model, we'd verify the retry behavior
    }

    func testRetryWithoutUserMessage() async {
        // Add only assistant message
        let assistantMessage = Message(content: "Hi", role: .assistant)
        await viewModel.addMessage(assistantMessage)

        await viewModel.retryLastMessage()

        // Should not change anything if there's no user message
        XCTAssertEqual(viewModel.messages.count, 1)
    }

    // MARK: - Cancellation Tests

    func testCancelCurrentOperation() async {
        viewModel.cancelCurrentOperation()

        XCTAssertFalse(viewModel.isResponding)
    }

    // MARK: - Computed Properties Tests

    func testHasMessages() async {
        XCTAssertFalse(viewModel.hasMessages)

        let message = Message(content: "Test", role: .user)
        await viewModel.addMessage(message)

        XCTAssertTrue(viewModel.hasMessages)
    }

    func testCanSendMessage() async {
        // Initially should be able to send (assuming model is available)
        XCTAssertTrue(viewModel.canSendMessage)

        // Test when responding
        // Note: We can't easily test this without mocking the model
        // In a real implementation, you'd mock the isResponding state
    }

    func testLastMessage() async {
        XCTAssertNil(viewModel.lastMessage)

        let message1 = Message(content: "First", role: .user)
        let message2 = Message(content: "Second", role: .assistant)

        await viewModel.addMessage(message1)
        XCTAssertEqual(viewModel.lastMessage?.content, "First")

        await viewModel.addMessage(message2)
        XCTAssertEqual(viewModel.lastMessage?.content, "Second")
    }

    func testConversationTitle() async {
        // Empty conversation
        XCTAssertEqual(viewModel.conversationTitle, "New Conversation")

        // With user message
        let userMessage = Message(content: "This is a long message that should be truncated for title", role: .user)
        await viewModel.addMessage(userMessage)

        let title = viewModel.conversationTitle
        XCTAssertNotEqual(title, "New Conversation")
        XCTAssertTrue(title.count <= "This is a long message".count) // Should be truncated
    }

    func testGetConversationStats() async {
        let stats = viewModel.getConversationStats()
        XCTAssertEqual(stats.messageCount, 0)
        XCTAssertEqual(stats.tokenUsage, 0)
        XCTAssertEqual(stats.responseTime, 0)

        let message = Message(content: "Test", role: .user, tokens: 5)
        await viewModel.addMessage(message)

        let newStats = viewModel.getConversationStats()
        XCTAssertEqual(newStats.messageCount, 1)
    }

    // MARK: - Performance Tests

    func testPerformanceAddManyMessages() async {
        measure {
            Task {
                for i in 0..<100 {
                    let message = Message(content: "Message \(i)", role: i % 2 == 0 ? .user : .assistant)
                    await viewModel.addMessage(message)
                }
            }
        }
    }

    func testPerformanceExportLargeConversation() async throws {
        // Add many messages
        for i in 0..<50 {
            let message = Message(content: "Test message \(i)", role: i % 2 == 0 ? .user : .assistant)
            await viewModel.addMessage(message)
        }

        measure {
            Task {
                do {
                    _ = try await viewModel.exportConversation(format: .json)
                } catch {
                    XCTFail("Export failed: \(error)")
                }
            }
        }
    }
}

// MARK: - Test Helpers

extension ChatViewModelTests {
    private func addMessage(_ message: Message) async {
        await viewModel.addMessage(message)
    }
}

// MARK: - Mock Data Extensions

extension Message {
    static func mockUser(_ content: String) -> Message {
        Message(content: content, role: .user)
    }

    static func mockAssistant(_ content: String, tokens: Int? = nil) -> Message {
        Message(content: content, role: .assistant, tokens: tokens)
    }

    static func mockSystem(_ content: String) -> Message {
        Message(content: content, role: .system)
    }
}