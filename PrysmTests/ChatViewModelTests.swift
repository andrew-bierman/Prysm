//
//  ChatViewModelTests.swift
//  PrysmTests
//
//  Testing the ChatViewModel with provider-based architecture
//

import Testing
import Foundation
@testable import Prysm

@MainActor
struct ChatViewModelTests {

    @Test("ViewModel initializes correctly")
    func testInitialization() async {
        let viewModel = ChatViewModel()

        #expect(viewModel.messages.isEmpty)
        #expect(!viewModel.isLoading)
        #expect(!viewModel.isStreaming)
        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.showError)
        #expect(viewModel.streamingContent.isEmpty)
    }

    @Test("Clear chat removes all messages")
    func testClearChat() async {
        let viewModel = ChatViewModel()

        // Add messages manually
        viewModel.messages.append(LLMMessage(role: .user, content: "Hello"))
        viewModel.messages.append(LLMMessage(role: .assistant, content: "Hi there!"))

        #expect(viewModel.messages.count == 2)

        viewModel.clearChat()

        #expect(viewModel.messages.isEmpty)
    }

    @Test("Base instructions default to AppConfig.assistantInstructions")
    func testInstructions() async {
        let viewModel = ChatViewModel()

        #expect(viewModel.baseInstructions == AppConfig.assistantInstructions)
        #expect(viewModel.instructions.contains(AppConfig.assistantInstructions))
    }

    @Test("Custom instructions are included when enabled")
    func testCustomInstructions() async {
        let viewModel = ChatViewModel()

        // Set custom instructions
        UserDefaults.standard.set(true, forKey: "useCustomInstructions")
        UserDefaults.standard.set("Be concise", forKey: "customInstructions")

        let instructions = viewModel.instructions

        #expect(instructions.contains(AppConfig.assistantInstructions))
        #expect(instructions.contains("Be concise"))

        // Clean up
        UserDefaults.standard.removeObject(forKey: "useCustomInstructions")
        UserDefaults.standard.removeObject(forKey: "customInstructions")
    }

    @Test("Remote config persistence updates provider")
    func testRemoteConfigPersistence() async {
        let viewModel = ChatViewModel()

        let config = RemoteProviderConfig(
            baseURL: "https://api.example.com",
            apiKey: "test-key-123",
            modelName: "gpt-4",
            organizationID: "org-123"
        )

        viewModel.updateRemoteConfig(config)

        #expect(viewModel.remoteProvider.config.baseURL == "https://api.example.com")
        #expect(viewModel.remoteProvider.config.modelName == "gpt-4")
        #expect(viewModel.remoteProvider.config.organizationID == "org-123")

        // Verify UserDefaults persistence
        #expect(UserDefaults.standard.string(forKey: "remoteBaseURL") == "https://api.example.com")
        #expect(UserDefaults.standard.string(forKey: "remoteModelName") == "gpt-4")
        #expect(UserDefaults.standard.string(forKey: "remoteOrganizationID") == "org-123")

        // Clean up
        UserDefaults.standard.removeObject(forKey: "remoteBaseURL")
        UserDefaults.standard.removeObject(forKey: "remoteModelName")
        UserDefaults.standard.removeObject(forKey: "remoteOrganizationID")
        KeychainHelper.delete(key: "remoteAPIKey")
    }

    @Test("Dismiss error clears error state")
    func testDismissError() async {
        let viewModel = ChatViewModel()

        viewModel.errorMessage = "Something went wrong"
        viewModel.showError = true

        #expect(viewModel.showError)
        #expect(viewModel.errorMessage == "Something went wrong")

        viewModel.dismissError()

        #expect(!viewModel.showError)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("isUsingRemote defaults to false")
    func testIsUsingRemote() async {
        // Ensure the key is not set to "remote"
        let saved = UserDefaults.standard.string(forKey: "selectedLanguageModel")
        UserDefaults.standard.set("default", forKey: "selectedLanguageModel")

        let viewModel = ChatViewModel()

        #expect(!viewModel.isUsingRemote)

        // Restore
        if let saved = saved {
            UserDefaults.standard.set(saved, forKey: "selectedLanguageModel")
        } else {
            UserDefaults.standard.removeObject(forKey: "selectedLanguageModel")
        }
    }

    @Test("Update instructions changes base instructions")
    func testUpdateInstructions() async {
        let viewModel = ChatViewModel()

        let newInstructions = "You are a helpful coding assistant."
        viewModel.updateInstructions(newInstructions)

        #expect(viewModel.baseInstructions == newInstructions)
    }

    @Test("Generation config reads from UserDefaults")
    func testGenerationConfig() async {
        UserDefaults.standard.set(0.9, forKey: "temperature")
        UserDefaults.standard.set(0.85, forKey: "topP")
        UserDefaults.standard.set(4096, forKey: "maxTokens")
        UserDefaults.standard.set(false, forKey: "streamResponses")

        let viewModel = ChatViewModel()
        let config = viewModel.generationConfig

        #expect(config.temperature == 0.9)
        #expect(config.topP == 0.85)
        #expect(config.maxTokens == 4096)
        #expect(config.stream == false)

        // Clean up
        UserDefaults.standard.removeObject(forKey: "temperature")
        UserDefaults.standard.removeObject(forKey: "topP")
        UserDefaults.standard.removeObject(forKey: "maxTokens")
        UserDefaults.standard.removeObject(forKey: "streamResponses")
    }
}

// MARK: - LLMMessage Tests

extension ChatViewModelTests {

    @Test("LLMMessage initializes with correct properties")
    func testLLMMessageInit() {
        let message = LLMMessage(role: .user, content: "Hello")

        #expect(message.role == .user)
        #expect(message.content == "Hello")
        #expect(message.id != UUID()) // Has a unique ID
    }

    @Test("LLMMessage roles are distinct")
    func testLLMMessageRoles() {
        let system = LLMMessage(role: .system, content: "System prompt")
        let user = LLMMessage(role: .user, content: "User message")
        let assistant = LLMMessage(role: .assistant, content: "Assistant response")

        #expect(system.role == .system)
        #expect(user.role == .user)
        #expect(assistant.role == .assistant)
        #expect(system.role != user.role)
    }

    @Test("LLMMessage equality is based on id")
    func testLLMMessageEquality() {
        let msg1 = LLMMessage(role: .user, content: "Hello")
        let msg2 = LLMMessage(role: .user, content: "Hello")

        // Two separately created messages should not be equal (different UUIDs)
        #expect(msg1 != msg2)
    }
}

// MARK: - GenerationConfig Tests

extension ChatViewModelTests {

    @Test("GenerationConfig defaults")
    func testGenerationConfigDefaults() {
        let config = GenerationConfig()

        #expect(config.temperature == 0.7)
        #expect(config.topP == 0.95)
        #expect(config.maxTokens == 2048)
        #expect(config.stream == true)
    }
}
