//
//  ChatViewModel.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import Foundation
import FoundationModels
import Observation

@Observable
final class ChatViewModel {

    // MARK: - Published Properties

    var isLoading: Bool = false
    var isSummarizing: Bool = false
    var isApplyingWindow: Bool = false
    var sessionCount: Int = 1
    var baseInstructions: String = AppConfig.assistantInstructions

    var instructions: String {
        var fullInstructions = ""

        // Only use base instructions if enabled
        let useBaseInstructions = UserDefaults.standard.object(forKey: "useBaseInstructions") as? Bool ?? true
        if useBaseInstructions {
            fullInstructions = baseInstructions
        }

        // Add custom instructions if enabled
        if UserDefaults.standard.bool(forKey: "useCustomInstructions") {
            if let customInstructions = UserDefaults.standard.string(forKey: "customInstructions"), !customInstructions.isEmpty {
                if !fullInstructions.isEmpty {
                    fullInstructions += "\n\n"
                }
                fullInstructions += "User's custom instructions:\n" + customInstructions
            }
        }

        return fullInstructions
    }
    var errorMessage: String?
    var showError: Bool = false

    // MARK: - Public Properties

    private(set) var session: LanguageModelSession

    // MARK: - Feedback State

    private(set) var feedbackState: [Transcript.Entry.ID: LanguageModelFeedback.Sentiment] = [:]

    // MARK: - Sliding Window Configuration
    private let windowThreshold = 0.75

    // MARK: - Generation Options (read from UserDefaults / @AppStorage)

    /// Reads the current generation options from UserDefaults, matching keys set by GenerationOptionsView.
    private var generationOptions: GenerationOptions {
        let defaults = UserDefaults.standard

        let temperature = defaults.object(forKey: "temperature") as? Double ?? 0.7
        let maxResponseTokens = defaults.object(forKey: "maxTokens") as? Int ?? 2048

        return GenerationOptions(
            temperature: temperature,
            maximumResponseTokens: maxResponseTokens
        )
    }

    /// Whether to stream responses (set in GenerationOptionsView).
    private var streamResponses: Bool {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: "streamResponses") as? Bool ?? true
    }

    /// Whether to auto-summarize when context window is exceeded (set in GenerationOptionsView).
    private var autoSummarize: Bool {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: "autoSummarize") as? Bool ?? true
    }

    /// Context window size for sliding window logic (set in GenerationOptionsView).
    private var contextWindowSize: Int {
        let defaults = UserDefaults.standard
        let value = defaults.integer(forKey: "contextWindowSize")
        return value > 0 ? value : 4096
    }

    /// Target window size is half the context window, used when trimming history.
    private var targetWindowSize: Int {
        return contextWindowSize / 2
    }

    // MARK: - Initialization

    init() {
        self.session = LanguageModelSession(
            instructions: Instructions(
                AppConfig.assistantInstructions
            )
        )
    }

    // MARK: - Public Methods

    @MainActor
    func sendMessage(_ content: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Check if we need to apply sliding window BEFORE sending
            if shouldApplyWindow() {
                await applySlidingWindow()
            }

            let options = generationOptions

            if streamResponses {
                // Stream response from current session
                let responseStream = session.streamResponse(to: Prompt(content), options: options)

                for try await _ in responseStream {
                    // The streaming automatically updates the session transcript
                }
            } else {
                // Non-streaming: wait for the full response
                _ = try await session.respond(to: Prompt(content), options: options)
            }

        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            // Fallback: Handle context window exceeded by summarizing and creating new session
            await handleContextWindowExceeded(userMessage: content)

        } catch {
            // Handle other errors by showing an error message
            errorMessage = handleFoundationModelsError(error)
            showError = true
        }
    }

    @MainActor
    func submitFeedback(for entryID: Transcript.Entry.ID, sentiment: LanguageModelFeedback.Sentiment) {
        // Store the feedback state
        feedbackState[entryID] = sentiment

        // Use the new session method to log feedback attachment
        _ = session.logFeedbackAttachment(sentiment: sentiment)
    }

    @MainActor
    func getFeedback(for entryID: Transcript.Entry.ID) -> LanguageModelFeedback.Sentiment? {
        return feedbackState[entryID]
    }

    @MainActor
    func clearChat() {
        sessionCount = 1
        feedbackState.removeAll()
        session = LanguageModelSession(
            instructions: Instructions(instructions)
        )
    }

    @MainActor
    func updateInstructions(_ newInstructions: String) {
        baseInstructions = newInstructions
        session = LanguageModelSession(
            instructions: Instructions(instructions)
        )
    }

    @MainActor
    func refreshSession() {
        // Refresh the session with potentially updated custom instructions
        session = LanguageModelSession(
            instructions: Instructions(instructions)
        )
    }

    // MARK: - Sliding Window Implementation

    private func shouldApplyWindow() -> Bool {
        return session.transcript.isApproachingLimit(threshold: windowThreshold, maxTokens: contextWindowSize)
    }

    @MainActor
    private func applySlidingWindow() async {
        isApplyingWindow = true

        // Get entries that fit within our target window size
        let windowEntries = session.transcript.entriesWithinTokenBudget(targetWindowSize)

        // Extract conversation history text from the kept entries
        let conversationHistory = windowEntries.compactMap { entry -> String? in
            switch entry {
            case .prompt(let prompt):
                let text = prompt.segments.compactMap { segment in
                    if case .text(let textSegment) = segment {
                        return textSegment.content
                    }
                    return nil
                }.joined(separator: " ")
                return "User: \(text)"
            case .response(let response):
                let text = response.segments.compactMap { segment in
                    if case .text(let textSegment) = segment {
                        return textSegment.content
                    }
                    return nil
                }.joined(separator: " ")
                return "Assistant: \(text)"
            default:
                return nil
            }
        }.joined(separator: "\n\n")

        // Create new session with kept history embedded in instructions
        // so the model retains context from the recent conversation
        if conversationHistory.isEmpty {
            session = LanguageModelSession(instructions: Instructions(instructions))
        } else {
            let contextInstructions = """
            \(instructions)

            You are continuing a conversation with the user. Here is the recent conversation history you should remember and continue from:

            RECENT CONVERSATION HISTORY:
            \(conversationHistory)

            Continue the conversation naturally, maintaining context from the history above.
            """
            session = LanguageModelSession(instructions: Instructions(contextInstructions))
        }

        sessionCount += 1

        isApplyingWindow = false
    }

    // MARK: - Private Methods (Existing)

    private func handleFoundationModelsError(_ error: Error) -> String {
        if let generationError = error as? LanguageModelSession.GenerationError {
            return FoundationModelsErrorHandler.handleGenerationError(generationError)
        } else if let toolCallError = error as? LanguageModelSession.ToolCallError {
            return FoundationModelsErrorHandler.handleToolCallError(toolCallError)
        } else if let customError = error as? FoundationModelsError {
            return customError.localizedDescription
        } else {
            return "Error: \(error)"
        }
    }

    @MainActor
    private func handleContextWindowExceeded(userMessage: String) async {
        if autoSummarize {
            isSummarizing = true

            do {
                let summary = try await generateConversationSummary()
                createNewSessionWithContext(summary: summary)
                isSummarizing = false

                try await respondWithNewSession(to: userMessage)
            } catch {
                handleSummarizationError(error)
                errorMessage = handleFoundationModelsError(error)
                showError = true
            }
        } else {
            // Without auto-summarize, just start a fresh session and retry
            session = LanguageModelSession(instructions: Instructions(instructions))
            sessionCount += 1

            do {
                try await respondWithNewSession(to: userMessage)
            } catch {
                errorMessage = handleFoundationModelsError(error)
                showError = true
            }
        }
    }

    private func createConversationText() -> String {
        return session.transcript.compactMap { entry in
            switch entry {
            case .prompt(let prompt):
                let text = prompt.segments.compactMap { segment in
                    if case .text(let textSegment) = segment {
                        return textSegment.content
                    }
                    return nil
                }.joined(separator: " ")
                return "User: \(text)"
            case .response(let response):
                let text = response.segments.compactMap { segment in
                    if case .text(let textSegment) = segment {
                        return textSegment.content
                    }
                    return nil
                }.joined(separator: " ")
                return "Assistant: \(text)"
            default:
                return nil
            }
        }.joined(separator: "\n\n")
    }

    @MainActor
    private func generateConversationSummary() async throws -> ConversationSummary {
        let summarySession = LanguageModelSession(
            instructions: Instructions(
                "You are an expert at summarizing conversations. Create comprehensive summaries that preserve all important context and details."
            )
        )

        let conversationText = createConversationText()
        let summaryPrompt = """
      Please summarize the following entire conversation comprehensively. Include all key points, topics discussed, user preferences, and important context that would help continue the conversation naturally:

      \(conversationText)
      """

        let summaryResponse = try await summarySession.respond(
            to: Prompt(summaryPrompt),
            generating: ConversationSummary.self
        )

        return summaryResponse.content
    }

    private func createNewSessionWithContext(summary: ConversationSummary) {
        let contextInstructions = """
      \(instructions)

      You are continuing a conversation with a user. Here's a summary of your previous conversation:

      CONVERSATION SUMMARY:
      \(summary.summary)

      KEY TOPICS DISCUSSED:
      \(summary.keyTopics.map { "• \($0)" }.joined(separator: "\n"))

      USER PREFERENCES/REQUESTS:
      \(summary.userPreferences.map { "• \($0)" }.joined(separator: "\n"))

      Continue the conversation naturally, referencing this context when relevant. The user's next message is a continuation of your previous discussion.
      """

        session = LanguageModelSession(instructions: Instructions(contextInstructions))
        sessionCount += 1
    }

    @MainActor
    private func respondWithNewSession(to userMessage: String) async throws {
        let options = generationOptions

        if streamResponses {
            let responseStream = session.streamResponse(to: Prompt(userMessage), options: options)

            for try await _ in responseStream {
                // The streaming automatically updates the session transcript
            }
        } else {
            _ = try await session.respond(to: Prompt(userMessage), options: options)
        }
    }

    @MainActor
    private func handleSummarizationError(_ error: Error) {
        isSummarizing = false
        errorMessage = error.localizedDescription
        showError = true
    }

    @MainActor
    func dismissError() {
        showError = false
        errorMessage = nil
    }
}