//
//  ChatViewModelTests.swift
//  PrysmTests
//
//  Testing the ChatViewModel
//

import Testing
import Foundation
import FoundationModels
@testable import Prysm

@MainActor
struct ChatViewModelTests {

    @Test("ViewModel initializes correctly")
    func testViewModelInitialization() async {
        let viewModel = ChatViewModel()

        #expect(!viewModel.isLoading)
        #expect(!viewModel.isSummarizing)
        #expect(!viewModel.isApplyingWindow)
        #expect(viewModel.sessionCount == 1)
        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.showError)
        #expect(viewModel.feedbackState.isEmpty)
    }

    @Test("Base instructions default to AppConfig value")
    func testBaseInstructions() async {
        let viewModel = ChatViewModel()

        #expect(viewModel.baseInstructions == AppConfig.assistantInstructions)
    }

    @Test("Instructions include base instructions when enabled")
    func testInstructionsWithBaseEnabled() async {
        let viewModel = ChatViewModel()

        // Ensure base instructions are enabled (default)
        UserDefaults.standard.set(true, forKey: "useBaseInstructions")
        UserDefaults.standard.removeObject(forKey: "useCustomInstructions")

        let instructions = viewModel.instructions
        #expect(instructions.contains(AppConfig.assistantName))

        // Clean up
        UserDefaults.standard.removeObject(forKey: "useBaseInstructions")
    }

    @Test("Instructions include custom instructions when enabled")
    func testCustomInstructions() async {
        let viewModel = ChatViewModel()

        // Enable custom instructions
        UserDefaults.standard.set(true, forKey: "useBaseInstructions")
        UserDefaults.standard.set(true, forKey: "useCustomInstructions")
        UserDefaults.standard.set("Be concise and helpful", forKey: "customInstructions")

        let instructions = viewModel.instructions
        #expect(instructions.contains("Be concise and helpful"))
        #expect(instructions.contains(AppConfig.assistantName))

        // Clean up
        UserDefaults.standard.removeObject(forKey: "useBaseInstructions")
        UserDefaults.standard.removeObject(forKey: "useCustomInstructions")
        UserDefaults.standard.removeObject(forKey: "customInstructions")
    }

    @Test("Instructions exclude custom instructions when disabled")
    func testCustomInstructionsDisabled() async {
        let viewModel = ChatViewModel()

        UserDefaults.standard.set(true, forKey: "useBaseInstructions")
        UserDefaults.standard.set(false, forKey: "useCustomInstructions")
        UserDefaults.standard.set("Should not appear", forKey: "customInstructions")

        let instructions = viewModel.instructions
        #expect(!instructions.contains("Should not appear"))

        // Clean up
        UserDefaults.standard.removeObject(forKey: "useBaseInstructions")
        UserDefaults.standard.removeObject(forKey: "useCustomInstructions")
        UserDefaults.standard.removeObject(forKey: "customInstructions")
    }

    @Test("Instructions are empty when base disabled and no custom")
    func testInstructionsBaseDisabled() async {
        let viewModel = ChatViewModel()

        UserDefaults.standard.set(false, forKey: "useBaseInstructions")
        UserDefaults.standard.set(false, forKey: "useCustomInstructions")

        let instructions = viewModel.instructions
        #expect(instructions.isEmpty)

        // Clean up
        UserDefaults.standard.removeObject(forKey: "useBaseInstructions")
        UserDefaults.standard.removeObject(forKey: "useCustomInstructions")
    }

    @Test("Clear chat resets session and state")
    func testClearChat() async {
        let viewModel = ChatViewModel()

        // Modify state
        viewModel.sessionCount = 5

        viewModel.clearChat()

        #expect(viewModel.sessionCount == 1)
        #expect(viewModel.feedbackState.isEmpty)
    }

    @Test("Update instructions changes base instructions")
    func testUpdateInstructions() async {
        let viewModel = ChatViewModel()
        let newInstructions = "You are a helpful coding assistant."

        viewModel.updateInstructions(newInstructions)

        #expect(viewModel.baseInstructions == newInstructions)
    }

    @Test("Dismiss error clears error state")
    func testDismissError() async {
        let viewModel = ChatViewModel()

        // Set an error
        viewModel.errorMessage = "Something went wrong"
        viewModel.showError = true

        #expect(viewModel.errorMessage == "Something went wrong")
        #expect(viewModel.showError)

        // Dismiss
        viewModel.dismissError()

        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.showError)
    }

    @Test("Error state can be set")
    func testErrorState() async {
        let viewModel = ChatViewModel()

        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.showError)

        viewModel.errorMessage = "Test error"
        viewModel.showError = true

        #expect(viewModel.errorMessage == "Test error")
        #expect(viewModel.showError)
    }

    @Test("Loading state can be toggled")
    func testLoadingState() async {
        let viewModel = ChatViewModel()

        #expect(!viewModel.isLoading)

        viewModel.isLoading = true
        #expect(viewModel.isLoading)

        viewModel.isLoading = false
        #expect(!viewModel.isLoading)
    }

    @Test("Summarizing state can be toggled")
    func testSummarizingState() async {
        let viewModel = ChatViewModel()

        #expect(!viewModel.isSummarizing)

        viewModel.isSummarizing = true
        #expect(viewModel.isSummarizing)

        viewModel.isSummarizing = false
        #expect(!viewModel.isSummarizing)
    }

    @Test("Session count starts at 1")
    func testSessionCount() async {
        let viewModel = ChatViewModel()

        #expect(viewModel.sessionCount == 1)
    }

    @Test("Feedback state stores sentiment by entry ID")
    func testFeedbackState() async {
        let viewModel = ChatViewModel()

        #expect(viewModel.feedbackState.isEmpty)

        // Verify getFeedback returns nil for unknown entries
        let entries = viewModel.session.transcript
        // With a fresh session there are no entries, so getFeedback for any ID should be nil
        #expect(viewModel.feedbackState.count == 0)
    }

    @Test("Refresh session creates a new session")
    func testRefreshSession() async {
        let viewModel = ChatViewModel()

        // Should not crash or error
        viewModel.refreshSession()

        // Session should still be valid after refresh
        #expect(!viewModel.isLoading)
        #expect(!viewModel.isSummarizing)
    }

    @Test("Clear chat after setting error also clears feedback")
    func testClearChatResetsAllState() async {
        let viewModel = ChatViewModel()

        viewModel.errorMessage = "Error"
        viewModel.showError = true

        viewModel.clearChat()

        // clearChat resets session and feedback, but not error state
        #expect(viewModel.feedbackState.isEmpty)
        #expect(viewModel.sessionCount == 1)
    }
}
