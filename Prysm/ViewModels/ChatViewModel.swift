//
//  ChatViewModel.swift
//  Prysm
//
//  Refactored to use LLMProvider protocol for multi-provider support.
//

import Foundation
import Observation

@Observable
@MainActor
final class ChatViewModel {

    // MARK: - Message History

    var messages: [LLMMessage] = []

    // MARK: - State

    var isLoading: Bool = false
    var isStreaming: Bool = false
    var streamingContent: String = ""
    var errorMessage: String?
    var showError: Bool = false

    // MARK: - Instructions

    var baseInstructions: String = AppConfig.assistantInstructions

    var instructions: String {
        var fullInstructions = ""

        let useBaseInstructions = UserDefaults.standard.object(forKey: "useBaseInstructions") as? Bool ?? true
        if useBaseInstructions {
            fullInstructions = baseInstructions
        }

        if UserDefaults.standard.bool(forKey: "useCustomInstructions") {
            if let customInstructions = UserDefaults.standard.string(forKey: "customInstructions"),
               !customInstructions.isEmpty {
                if !fullInstructions.isEmpty {
                    fullInstructions += "\n\n"
                }
                fullInstructions += "User's custom instructions:\n" + customInstructions
            }
        }

        return fullInstructions
    }

    // MARK: - Providers

    private(set) var onDeviceProvider: OnDeviceProvider
    private(set) var remoteProvider: RemoteProvider

    var isUsingRemote: Bool {
        UserDefaults.standard.string(forKey: "selectedLanguageModel") == "remote"
    }

    var currentProvider: any LLMProvider {
        isUsingRemote ? remoteProvider : onDeviceProvider
    }

    // MARK: - Generation Config

    var generationConfig: GenerationConfig {
        let temperature = UserDefaults.standard.object(forKey: "temperature") as? Double ?? 0.7
        let topP = UserDefaults.standard.object(forKey: "topP") as? Double ?? 0.95
        let maxTokens = UserDefaults.standard.object(forKey: "maxTokens") as? Int ?? 2048
        let stream = UserDefaults.standard.object(forKey: "streamResponses") as? Bool ?? true
        return GenerationConfig(
            temperature: temperature,
            topP: topP,
            maxTokens: maxTokens,
            stream: stream
        )
    }

    // MARK: - Initialization

    init() {
        self.onDeviceProvider = OnDeviceProvider(systemPrompt: AppConfig.assistantInstructions)

        // Load saved remote config from UserDefaults + Keychain
        let baseURL = UserDefaults.standard.string(forKey: "remoteBaseURL") ?? "http://localhost:1234"
        let modelName = UserDefaults.standard.string(forKey: "remoteModelName") ?? "default"
        let apiKey = KeychainHelper.load(key: "remoteAPIKey") ?? ""
        let organizationID = UserDefaults.standard.string(forKey: "remoteOrganizationID") ?? ""

        let remoteConfig = RemoteProviderConfig(
            baseURL: baseURL,
            apiKey: apiKey,
            modelName: modelName,
            organizationID: organizationID
        )
        self.remoteProvider = RemoteProvider(config: remoteConfig)
    }

    // MARK: - Public Methods

    func sendMessage(_ content: String) async {
        let userMessage = LLMMessage(role: .user, content: content)
        messages.append(userMessage)

        // Create a placeholder assistant message for streaming
        let assistantPlaceholder = LLMMessage(role: .assistant, content: "")
        messages.append(assistantPlaceholder)
        let assistantIndex = messages.count - 1
        let assistantID = assistantPlaceholder.id

        isLoading = true
        isStreaming = true
        streamingContent = ""

        do {
            // Build history from all messages except the last user message and placeholder
            let history = Array(messages.dropLast(2))

            let stream = currentProvider.sendMessage(
                content,
                history: history,
                systemPrompt: instructions,
                config: generationConfig
            )

            var accumulated = ""
            for try await delta in stream {
                accumulated += delta
                streamingContent = accumulated

                // Replace the placeholder message with updated content
                messages[assistantIndex] = LLMMessage(role: .assistant, content: accumulated)
            }

            // Final update — ensure content is set even if stream ended without deltas
            if messages[assistantIndex].content.isEmpty && !accumulated.isEmpty {
                messages[assistantIndex] = LLMMessage(role: .assistant, content: accumulated)
            }

        } catch {
            // Remove the empty placeholder if streaming failed before producing content
            if messages.count > assistantIndex,
               messages[assistantIndex].id == assistantID,
               messages[assistantIndex].content.isEmpty {
                messages.remove(at: assistantIndex)
            }

            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
        isStreaming = false
        streamingContent = ""
    }

    func clearChat() {
        messages.removeAll()
        onDeviceProvider.resetSession(systemPrompt: instructions)
    }

    func updateInstructions(_ newInstructions: String) {
        baseInstructions = newInstructions
        onDeviceProvider.resetSession(systemPrompt: instructions)
    }

    func refreshSession() {
        onDeviceProvider.resetSession(systemPrompt: instructions)
    }

    func updateRemoteConfig(_ config: RemoteProviderConfig) {
        remoteProvider.config = config

        // Persist non-sensitive values to UserDefaults
        UserDefaults.standard.set(config.baseURL, forKey: "remoteBaseURL")
        UserDefaults.standard.set(config.modelName, forKey: "remoteModelName")
        UserDefaults.standard.set(config.organizationID, forKey: "remoteOrganizationID")

        // Persist API key to Keychain
        if !config.apiKey.isEmpty {
            _ = KeychainHelper.save(key: "remoteAPIKey", value: config.apiKey)
        } else {
            KeychainHelper.delete(key: "remoteAPIKey")
        }
    }

    func dismissError() {
        showError = false
        errorMessage = nil
    }
}
