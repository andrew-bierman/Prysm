//
//  ChatViewModelTests.swift
//  PrismTests
//
//  Testing the ChatViewModel
//

import Testing
import Foundation
import FoundationModels
@testable import Prism

@MainActor
struct ChatViewModelTests {

    @Test("ViewModel initializes correctly")
    func testViewModelInitialization() async {
        let viewModel = ChatViewModel()

        #expect(viewModel.entries.isEmpty)
        #expect(!viewModel.isLoading)
        #expect(!viewModel.isSummarizing)
        #expect(viewModel.currentError == nil)
        #expect(viewModel.conversationId != nil)
    }

    @Test("Send message adds entries correctly")
    func testSendMessage() async {
        let viewModel = ChatViewModel()
        let testMessage = "Hello, test"

        // Mock sending message (would normally interact with model)
        viewModel.entries.append(Transcript.Entry(role: .user, content: testMessage))

        #expect(viewModel.entries.count == 1)
        #expect(viewModel.entries.first?.content == testMessage)
        #expect(viewModel.entries.first?.role == .user)
    }

    @Test("Clear conversation removes all entries")
    func testClearConversation() async {
        let viewModel = ChatViewModel()

        // Add test entries
        viewModel.entries.append(Transcript.Entry(role: .user, content: "Test 1"))
        viewModel.entries.append(Transcript.Entry(role: .assistant, content: "Response 1"))

        #expect(viewModel.entries.count == 2)

        // Clear conversation
        viewModel.clearConversation()

        #expect(viewModel.entries.isEmpty)
        #expect(viewModel.conversationId != nil) // Should have new ID
    }

    @Test("Delete entry at index works correctly")
    func testDeleteEntry() async {
        let viewModel = ChatViewModel()

        // Add test entries
        viewModel.entries.append(Transcript.Entry(role: .user, content: "Message 1"))
        viewModel.entries.append(Transcript.Entry(role: .assistant, content: "Response 1"))
        viewModel.entries.append(Transcript.Entry(role: .user, content: "Message 2"))

        #expect(viewModel.entries.count == 3)

        // Delete middle entry
        viewModel.deleteEntry(at: 1)

        #expect(viewModel.entries.count == 2)
        #expect(viewModel.entries[0].content == "Message 1")
        #expect(viewModel.entries[1].content == "Message 2")
    }

    @Test("Retry last message removes assistant response")
    func testRetryLastMessage() async {
        let viewModel = ChatViewModel()

        // Add entries
        viewModel.entries.append(Transcript.Entry(role: .user, content: "User message"))
        viewModel.entries.append(Transcript.Entry(role: .assistant, content: "Assistant response"))

        // Find last user message
        if let lastUserIndex = viewModel.entries.lastIndex(where: { $0.role == .user }) {
            // Remove all entries after the last user message
            viewModel.entries.removeLast(viewModel.entries.count - lastUserIndex - 1)
        }

        #expect(viewModel.entries.count == 1)
        #expect(viewModel.entries.last?.role == .user)
    }

    @Test("Export conversation to JSON format")
    func testExportJSON() async throws {
        let viewModel = ChatViewModel()

        // Add test entries
        viewModel.entries.append(Transcript.Entry(role: .user, content: "Hello"))
        viewModel.entries.append(Transcript.Entry(role: .assistant, content: "Hi there!"))

        let exportData = viewModel.exportConversation(format: .json)

        #expect(exportData != nil)

        if let data = exportData {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            #expect(json != nil)
            #expect(json?["messageCount"] as? Int == 2)
        }
    }

    @Test("Export conversation to Markdown format")
    func testExportMarkdown() async {
        let viewModel = ChatViewModel()

        // Add test entries
        viewModel.entries.append(Transcript.Entry(role: .user, content: "Test message"))
        viewModel.entries.append(Transcript.Entry(role: .assistant, content: "Test response"))

        let exportData = viewModel.exportConversation(format: .markdown)

        #expect(exportData != nil)

        if let data = exportData,
           let markdown = String(data: data, encoding: .utf8) {
            #expect(markdown.contains("# Conversation"))
            #expect(markdown.contains("## User"))
            #expect(markdown.contains("## Assistant"))
            #expect(markdown.contains("Test message"))
            #expect(markdown.contains("Test response"))
        }
    }

    @Test("Export conversation to plain text format")
    func testExportPlainText() async {
        let viewModel = ChatViewModel()

        // Add test entries
        viewModel.entries.append(Transcript.Entry(role: .user, content: "Plain text test"))

        let exportData = viewModel.exportConversation(format: .plainText)

        #expect(exportData != nil)

        if let data = exportData,
           let text = String(data: data, encoding: .utf8) {
            #expect(text.contains("USER: Plain text test"))
        }
    }

    @Test("Export conversation to CSV format")
    func testExportCSV() async {
        let viewModel = ChatViewModel()

        // Add test entries
        viewModel.entries.append(Transcript.Entry(role: .user, content: "CSV test"))

        let exportData = viewModel.exportConversation(format: .csv)

        #expect(exportData != nil)

        if let data = exportData,
           let csv = String(data: data, encoding: .utf8) {
            #expect(csv.contains("Timestamp,Role,Content"))
            #expect(csv.contains("\"user\",\"CSV test\""))
        }
    }

    @Test("Custom instructions are included in prompt")
    func testCustomInstructions() async {
        let viewModel = ChatViewModel()

        // Set custom instructions
        UserDefaults.standard.set(true, forKey: "useCustomInstructions")
        UserDefaults.standard.set("Be concise", forKey: "customInstructions")

        let instructions = viewModel.instructions

        #expect(instructions.contains("You are Prism"))
        #expect(instructions.contains("Be concise"))

        // Clean up
        UserDefaults.standard.removeObject(forKey: "useCustomInstructions")
        UserDefaults.standard.removeObject(forKey: "customInstructions")
    }

    @Test("Conversation title generation")
    func testConversationTitle() async {
        let viewModel = ChatViewModel()

        // Empty conversation
        #expect(viewModel.conversationTitle == "New Conversation")

        // Add user message
        viewModel.entries.append(Transcript.Entry(role: .user, content: "This is a test message"))

        let title = viewModel.conversationTitle
        #expect(title != "New Conversation")
        #expect(title == "This is a test message")

        // Test truncation with long message
        viewModel.entries.removeAll()
        let longMessage = String(repeating: "A", count: 100)
        viewModel.entries.append(Transcript.Entry(role: .user, content: longMessage))

        let truncatedTitle = viewModel.conversationTitle
        #expect(truncatedTitle.count <= 50)
    }

    @Test("Has messages computed property")
    func testHasMessages() async {
        let viewModel = ChatViewModel()

        #expect(!viewModel.hasMessages)

        viewModel.entries.append(Transcript.Entry(role: .user, content: "Test"))

        #expect(viewModel.hasMessages)
    }

    @Test("Last entry computed property")
    func testLastEntry() async {
        let viewModel = ChatViewModel()

        #expect(viewModel.lastEntry == nil)

        viewModel.entries.append(Transcript.Entry(role: .user, content: "First"))
        #expect(viewModel.lastEntry?.content == "First")

        viewModel.entries.append(Transcript.Entry(role: .assistant, content: "Second"))
        #expect(viewModel.lastEntry?.content == "Second")
    }

    @Test("Can send message when not loading")
    func testCanSendMessage() async {
        let viewModel = ChatViewModel()

        #expect(viewModel.canSendMessage)

        viewModel.isLoading = true
        #expect(!viewModel.canSendMessage)

        viewModel.isLoading = false
        #expect(viewModel.canSendMessage)
    }

    @Test("Error handling")
    func testErrorHandling() async {
        let viewModel = ChatViewModel()

        #expect(viewModel.currentError == nil)

        viewModel.currentError = "Test error"
        #expect(viewModel.currentError == "Test error")

        viewModel.clearError()
        #expect(viewModel.currentError == nil)
    }
}

// MARK: - Performance Tests

extension ChatViewModelTests {
    @Test("Performance: Add many entries")
    func testPerformanceAddManyEntries() async {
        let viewModel = ChatViewModel()

        for i in 0..<100 {
            let entry = Transcript.Entry(
                role: i % 2 == 0 ? .user : .assistant,
                content: "Message \(i)"
            )
            viewModel.entries.append(entry)
        }

        #expect(viewModel.entries.count == 100)
    }

    @Test("Performance: Export large conversation")
    func testPerformanceExportLargeConversation() async {
        let viewModel = ChatViewModel()

        // Add many entries
        for i in 0..<50 {
            let entry = Transcript.Entry(
                role: i % 2 == 0 ? .user : .assistant,
                content: "Test message \(i) with some content to make it more realistic"
            )
            viewModel.entries.append(entry)
        }

        let exportData = viewModel.exportConversation(format: .json)
        #expect(exportData != nil)
    }
}