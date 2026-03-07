# OpenAI-Compatible Remote API Support

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Allow users to connect Prysm to any OpenAI-compatible API (LM Studio, Ollama, OpenAI, etc.) as an alternative to on-device Apple Intelligence.

**Architecture:** Introduce an `LLMProvider` protocol that abstracts message sending/streaming. Two implementations: `OnDeviceProvider` (wraps existing FoundationModels) and `RemoteProvider` (OpenAI-compatible HTTP). ChatViewModel switches between providers. ChatView is refactored to use our own message array instead of FoundationModels' `Transcript` directly, enabling both providers to feed the same UI.

**Tech Stack:** Swift 6, SwiftUI, URLSession (async/await + AsyncStream for SSE streaming), Keychain (via Security framework), existing MVVM architecture.

---

## Overview

### Current State
- `ChatViewModel` is tightly coupled to `LanguageModelSession` (FoundationModels)
- `ChatView` iterates `viewModel.session.transcript` (a FoundationModels type)
- Zero networking code exists
- No API key storage

### Target State
- `ChatViewModel` uses an `LLMProvider` protocol
- `ChatView` uses our own `[ChatMessage]` array (populated by either provider)
- Users can configure remote endpoints in Settings (URL, API key, model name)
- Streaming works for both on-device and remote
- Secure API key storage via Keychain

### Key Design Decisions
1. **Protocol-based abstraction** — not a full rewrite, just wrapping existing code
2. **Own message history** — we can't use `Transcript` for remote, so ChatView must use our `[ChatMessage]` array for both modes
3. **SSE streaming** — OpenAI-compatible APIs use Server-Sent Events; we parse these with `URLSession.bytes`
4. **Keychain for secrets** — API keys stored securely, never in UserDefaults
5. **No third-party dependencies** — pure URLSession + Foundation

---

## Task 1: Create the LLMProvider Protocol and Message Types

**Files:**
- Create: `Prysm/Services/LLMProvider.swift`

**Step 1: Write the provider protocol and supporting types**

```swift
//
//  LLMProvider.swift
//  Prysm
//

import Foundation

/// A single message in a conversation
struct LLMMessage: Identifiable, Equatable {
    let id: UUID
    let role: Role
    var content: String
    let timestamp: Date

    enum Role: String, Codable {
        case system
        case user
        case assistant
    }

    init(role: Role, content: String) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
    }
}

/// Configuration for generation
struct GenerationConfig {
    var temperature: Double = 0.7
    var topP: Double = 0.95
    var maxTokens: Int = 2048
    var stream: Bool = true
}

/// Protocol that all LLM backends must conform to
@MainActor
protocol LLMProvider {
    /// Send a message and get a streaming response
    func sendMessage(
        _ content: String,
        history: [LLMMessage],
        systemPrompt: String,
        config: GenerationConfig
    ) -> AsyncThrowingStream<String, Error>

    /// Display name for this provider
    var displayName: String { get }

    /// Whether this provider is currently available
    var isAvailable: Bool { get }
}
```

**Step 2: Verify it compiles**

Run: `cd /Users/andrewbierman/Code/Prysm && xcodebuild -scheme Prysm -destination 'platform=macOS' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add Prysm/Services/LLMProvider.swift
git commit -m "feat: add LLMProvider protocol and LLMMessage type"
```

---

## Task 2: Create the OnDeviceProvider (Wrap Existing FoundationModels)

**Files:**
- Create: `Prysm/Services/OnDeviceProvider.swift`

**Step 1: Write the on-device provider**

```swift
//
//  OnDeviceProvider.swift
//  Prysm
//

import Foundation
import FoundationModels

@Observable
final class OnDeviceProvider: LLMProvider {
    private var session: LanguageModelSession

    var displayName: String { "On-Device Model" }

    var isAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }

    init(systemPrompt: String = AppConfig.assistantInstructions) {
        self.session = LanguageModelSession(
            instructions: Instructions(systemPrompt)
        )
    }

    func sendMessage(
        _ content: String,
        history: [LLMMessage],
        systemPrompt: String,
        config: GenerationConfig
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task { @MainActor in
                do {
                    // Recreate session if system prompt changed
                    self.session = LanguageModelSession(
                        instructions: Instructions(systemPrompt)
                    )

                    let responseStream = self.session.streamResponse(to: Prompt(content))
                    var fullText = ""

                    for try await partialResponse in responseStream {
                        // Extract current full text from transcript
                        if let lastEntry = self.session.transcript.last,
                           case .response(let response) = lastEntry {
                            let currentText = response.segments.compactMap { segment in
                                if case .text(let textSegment) = segment {
                                    return textSegment.content
                                }
                                return nil
                            }.joined(separator: " ")

                            if currentText != fullText {
                                let delta = String(currentText.dropFirst(fullText.count))
                                fullText = currentText
                                continuation.yield(delta)
                            }
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    func resetSession(systemPrompt: String) {
        session = LanguageModelSession(
            instructions: Instructions(systemPrompt)
        )
    }
}
```

**Step 2: Verify it compiles**

Run: `cd /Users/andrewbierman/Code/Prysm && xcodebuild -scheme Prysm -destination 'platform=macOS' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add Prysm/Services/OnDeviceProvider.swift
git commit -m "feat: add OnDeviceProvider wrapping FoundationModels"
```

---

## Task 3: Create the RemoteProvider (OpenAI-Compatible HTTP Client)

**Files:**
- Create: `Prysm/Services/RemoteProvider.swift`

**Step 1: Write the remote provider with SSE streaming**

```swift
//
//  RemoteProvider.swift
//  Prysm
//

import Foundation

/// Configuration for connecting to an OpenAI-compatible API
struct RemoteProviderConfig: Codable, Equatable {
    var baseURL: String = "http://localhost:1234"
    var apiKey: String = ""
    var modelName: String = "default"
    var organizationID: String = ""

    var chatCompletionsURL: URL? {
        URL(string: "\(baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/")))/v1/chat/completions")
    }
}

@Observable
final class RemoteProvider: LLMProvider {
    var config: RemoteProviderConfig
    private let urlSession: URLSession

    var displayName: String { "Remote: \(config.modelName)" }

    var isAvailable: Bool {
        config.chatCompletionsURL != nil && !config.baseURL.isEmpty
    }

    init(config: RemoteProviderConfig = RemoteProviderConfig()) {
        self.config = config
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 120
        self.urlSession = URLSession(configuration: sessionConfig)
    }

    func sendMessage(
        _ content: String,
        history: [LLMMessage],
        systemPrompt: String,
        config generationConfig: GenerationConfig
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    guard let url = self.config.chatCompletionsURL else {
                        throw RemoteProviderError.invalidURL
                    }

                    // Build messages array
                    var messages: [[String: String]] = []

                    if !systemPrompt.isEmpty {
                        messages.append(["role": "system", "content": systemPrompt])
                    }

                    for msg in history {
                        messages.append(["role": msg.role.rawValue, "content": msg.content])
                    }

                    messages.append(["role": "user", "content": content])

                    // Build request body
                    let body: [String: Any] = [
                        "model": self.config.modelName,
                        "messages": messages,
                        "temperature": generationConfig.temperature,
                        "top_p": generationConfig.topP,
                        "max_tokens": generationConfig.maxTokens,
                        "stream": generationConfig.stream
                    ]

                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                    if !self.config.apiKey.isEmpty {
                        request.setValue("Bearer \(self.config.apiKey)", forHTTPHeaderField: "Authorization")
                    }

                    if !self.config.organizationID.isEmpty {
                        request.setValue(self.config.organizationID, forHTTPHeaderField: "OpenAI-Organization")
                    }

                    request.httpBody = try JSONSerialization.data(withJSONObject: body)

                    if generationConfig.stream {
                        try await self.streamResponse(request: request, continuation: continuation)
                    } else {
                        try await self.nonStreamResponse(request: request, continuation: continuation)
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // MARK: - Private

    private func streamResponse(
        request: URLRequest,
        continuation: AsyncThrowingStream<String, Error>.Continuation
    ) async throws {
        let (bytes, response) = try await urlSession.bytes(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw RemoteProviderError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to read error body
            var errorBody = ""
            for try await line in bytes.lines {
                errorBody += line
            }
            throw RemoteProviderError.httpError(statusCode: httpResponse.statusCode, body: errorBody)
        }

        for try await line in bytes.lines {
            guard line.hasPrefix("data: ") else { continue }

            let data = String(line.dropFirst(6))

            if data == "[DONE]" { break }

            guard let jsonData = data.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let delta = firstChoice["delta"] as? [String: Any],
                  let content = delta["content"] as? String else {
                continue
            }

            continuation.yield(content)
        }

        continuation.finish()
    }

    private func nonStreamResponse(
        request: URLRequest,
        continuation: AsyncThrowingStream<String, Error>.Continuation
    ) async throws {
        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw RemoteProviderError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw RemoteProviderError.httpError(statusCode: httpResponse.statusCode, body: body)
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw RemoteProviderError.decodingError
        }

        continuation.yield(content)
        continuation.finish()
    }
}

enum RemoteProviderError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, body: String)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API endpoint URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode, let body):
            return "HTTP \(statusCode): \(body.prefix(200))"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
```

**Step 2: Verify it compiles**

Run: `cd /Users/andrewbierman/Code/Prysm && xcodebuild -scheme Prysm -destination 'platform=macOS' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add Prysm/Services/RemoteProvider.swift
git commit -m "feat: add RemoteProvider with OpenAI-compatible SSE streaming"
```

---

## Task 4: Create KeychainHelper for Secure API Key Storage

**Files:**
- Create: `Prysm/Services/KeychainHelper.swift`

**Step 1: Write keychain helper**

```swift
//
//  KeychainHelper.swift
//  Prysm
//

import Foundation
import Security

enum KeychainHelper {
    private static let service = "com.andrewbierman.prysm"

    static func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        // Delete existing item first
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        return status == errSecSuccess
    }

    static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
```

**Step 2: Verify it compiles**

Run: `cd /Users/andrewbierman/Code/Prysm && xcodebuild -scheme Prysm -destination 'platform=macOS' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add Prysm/Services/KeychainHelper.swift
git commit -m "feat: add KeychainHelper for secure API key storage"
```

---

## Task 5: Refactor ChatViewModel to Use LLMProvider Protocol

This is the core refactor. ChatViewModel stops using `LanguageModelSession` directly and instead uses an `LLMProvider`. It maintains its own `[LLMMessage]` history.

**Files:**
- Modify: `Prysm/ViewModels/ChatViewModel.swift`

**Step 1: Rewrite ChatViewModel**

Replace the entire contents of `ChatViewModel.swift` with:

```swift
//
//  ChatViewModel.swift
//  Prysm
//

import Foundation
import FoundationModels
import Observation

@Observable
final class ChatViewModel {

    // MARK: - Published Properties

    var messages: [LLMMessage] = []
    var isLoading: Bool = false
    var isStreaming: Bool = false
    var streamingContent: String = ""
    var errorMessage: String?
    var showError: Bool = false
    var baseInstructions: String = AppConfig.assistantInstructions

    // MARK: - Provider

    private(set) var activeProvider: (any LLMProvider)?
    private(set) var onDeviceProvider: OnDeviceProvider
    private(set) var remoteProvider: RemoteProvider

    var isUsingRemote: Bool {
        UserDefaults.standard.string(forKey: "selectedLanguageModel") == "remote"
    }

    var currentProvider: any LLMProvider {
        isUsingRemote ? remoteProvider : onDeviceProvider
    }

    var instructions: String {
        var fullInstructions = ""

        let useBaseInstructions = UserDefaults.standard.object(forKey: "useBaseInstructions") as? Bool ?? true
        if useBaseInstructions {
            fullInstructions = baseInstructions
        }

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

    // MARK: - Generation Config

    var generationConfig: GenerationConfig {
        GenerationConfig(
            temperature: UserDefaults.standard.object(forKey: "temperature") as? Double ?? 0.7,
            topP: UserDefaults.standard.object(forKey: "topP") as? Double ?? 0.95,
            maxTokens: UserDefaults.standard.object(forKey: "maxTokens") as? Int ?? 2048,
            stream: UserDefaults.standard.object(forKey: "streamResponses") as? Bool ?? true
        )
    }

    // MARK: - Initialization

    init() {
        self.onDeviceProvider = OnDeviceProvider(systemPrompt: AppConfig.assistantInstructions)
        self.remoteProvider = RemoteProvider()

        // Load saved remote config
        if let baseURL = UserDefaults.standard.string(forKey: "remoteBaseURL") {
            self.remoteProvider.config.baseURL = baseURL
        }
        if let modelName = UserDefaults.standard.string(forKey: "remoteModelName") {
            self.remoteProvider.config.modelName = modelName
        }
        if let apiKey = KeychainHelper.load(key: "remoteAPIKey") {
            self.remoteProvider.config.apiKey = apiKey
        }
    }

    // MARK: - Public Methods

    @MainActor
    func sendMessage(_ content: String) async {
        let userMessage = LLMMessage(role: .user, content: content)
        messages.append(userMessage)

        isLoading = true
        isStreaming = true
        streamingContent = ""

        // Add placeholder assistant message for streaming
        let assistantMessage = LLMMessage(role: .assistant, content: "")
        messages.append(assistantMessage)
        let assistantIndex = messages.count - 1

        do {
            let stream = currentProvider.sendMessage(
                content,
                history: Array(messages.dropLast(2)), // exclude current user msg + placeholder
                systemPrompt: instructions,
                config: generationConfig
            )

            for try await delta in stream {
                streamingContent += delta
                messages[assistantIndex] = LLMMessage(role: .assistant, content: streamingContent)
            }

        } catch {
            // Remove the placeholder if it's still empty
            if messages[assistantIndex].content.isEmpty {
                messages.remove(at: assistantIndex)
            }
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
        isStreaming = false
        streamingContent = ""
    }

    @MainActor
    func clearChat() {
        messages.removeAll()
        onDeviceProvider.resetSession(systemPrompt: instructions)
    }

    @MainActor
    func updateInstructions(_ newInstructions: String) {
        baseInstructions = newInstructions
        onDeviceProvider.resetSession(systemPrompt: instructions)
    }

    @MainActor
    func refreshSession() {
        onDeviceProvider.resetSession(systemPrompt: instructions)
    }

    @MainActor
    func updateRemoteConfig(_ config: RemoteProviderConfig) {
        remoteProvider.config = config
        // Persist non-secret config
        UserDefaults.standard.set(config.baseURL, forKey: "remoteBaseURL")
        UserDefaults.standard.set(config.modelName, forKey: "remoteModelName")
        // API key goes to Keychain
        if !config.apiKey.isEmpty {
            _ = KeychainHelper.save(key: "remoteAPIKey", value: config.apiKey)
        }
    }

    @MainActor
    func dismissError() {
        showError = false
        errorMessage = nil
    }
}
```

**Step 2: Verify it compiles (expect errors in views — we fix those next)**

Run: `cd /Users/andrewbierman/Code/Prysm && xcodebuild -scheme Prysm -destination 'platform=macOS' build 2>&1 | grep "error:" | head -20`
Expected: Errors related to `session.transcript` usage in ChatView, TranscriptEntryView, etc. This is expected.

**Step 3: Commit**

```bash
git add Prysm/ViewModels/ChatViewModel.swift
git commit -m "refactor: ChatViewModel to use LLMProvider protocol with own message history"
```

---

## Task 6: Refactor ChatView to Use LLMMessage Array

The chat view currently iterates over `session.transcript` (FoundationModels type). Refactor it to use our `messages` array.

**Files:**
- Modify: `Prysm/Views/ChatView.swift`
- Modify: `Prysm/Views/TranscriptEntryView.swift` → rename to `Prysm/Views/MessageView.swift`
- Modify: `Prysm/Views/Components/MessageBubbleView.swift`
- Modify: `Prysm/Views/Components/ChatInputView.swift`

**Step 1: Replace TranscriptEntryView with a simpler MessageView**

Replace contents of `Prysm/Views/TranscriptEntryView.swift`:

```swift
//
//  MessageView.swift
//  Prysm
//

import SwiftUI

struct MessageView: View {
    let message: LLMMessage

    var body: some View {
        switch message.role {
        case .user:
            MessageBubbleView(
                content: message.content,
                isFromUser: true,
                timestamp: message.timestamp
            )
        case .assistant:
            MessageBubbleView(
                content: message.content,
                isFromUser: false,
                timestamp: message.timestamp
            )
        case .system:
            EmptyView()
        }
    }
}

#if canImport(Markdown)
import Markdown

struct MarkdownTextView: View {
    let content: String

    var body: some View {
        Markdown(content: content)
            .textSelection(.enabled)
    }
}
#else
struct MarkdownTextView: View {
    let content: String

    var body: some View {
        Text(content)
            .textSelection(.enabled)
    }
}
#endif
```

**Step 2: Simplify MessageBubbleView to not depend on ChatMessage or ChatViewModel**

Replace contents of `Prysm/Views/Components/MessageBubbleView.swift`:

```swift
//
//  MessageBubbleView.swift
//  Prysm
//

import SwiftUI

struct MessageBubbleView: View {
    let content: String
    let isFromUser: Bool
    let timestamp: Date

    var body: some View {
        HStack {
            if isFromUser {
                Spacer(minLength: 60)
                messageContent
            } else {
                messageContent
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal)
    }

    private var messageContent: some View {
        VStack(alignment: isFromUser ? .trailing : .leading, spacing: Spacing.xSmall) {
            MarkdownTextView(content: content)
                .padding(.horizontal, Spacing.medium)
                .padding(.vertical, Spacing.small)
                .frame(maxWidth: .infinity, alignment: isFromUser ? .trailing : .leading)
                .background(
                    isFromUser ?
                    Color.accentColor : Color.gray.opacity(0.2)
                )
                .foregroundStyle(
                    isFromUser ? .white : .primary
                )
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))

            Text(timestamp, style: .relative)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
```

**Step 3: Update ChatView to use messages array**

Replace contents of `Prysm/Views/ChatView.swift`:

```swift
//
//  ChatView.swift
//  Prysm
//

import SwiftUI

struct ChatView: View {
    @Binding var viewModel: ChatViewModel
    @State private var scrollID: String?
    @State private var messageText = ""
    @State private var showInstructionsSheet = false
    @AppStorage("useCustomInstructions") private var useCustomInstructions = false
    @AppStorage("customInstructions") private var customInstructions = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            messagesView
                .contentShape(Rectangle())
                .onTapGesture {
                    isTextFieldFocused = false
                }

            ChatInputView(
                messageText: $messageText,
                isLoading: viewModel.isLoading,
                isTextFieldFocused: $isTextFieldFocused,
                onSend: { content in
                    Task {
                        await viewModel.sendMessage(content)
                    }
                }
            )
        }
        .navigationTitle("Chat")
#if os(iOS)
        .navigationBarTitleDisplayMode(.large)
#endif
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if viewModel.isUsingRemote {
                    Text("Remote")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.purple.opacity(0.2))
                        .clipShape(Capsule())
                }

                Button(action: { showInstructionsSheet = true }) {
                    Label("Instructions", systemImage: useCustomInstructions ? "doc.text.fill" : "doc.text")
                        .foregroundStyle(useCustomInstructions ? Color.accentColor : Color.primary)
                }
                .help("Customize AI behavior")

                Menu {
                    Button("Clear Chat", role: .destructive) {
                        viewModel.clearChat()
                    }
                    .disabled(viewModel.messages.isEmpty)
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showInstructionsSheet) {
            InstructionsSheet(isPresented: $showInstructionsSheet)
        }
        .onChange(of: useCustomInstructions) { _, _ in
            viewModel.refreshSession()
        }
        .onChange(of: customInstructions) { _, _ in
            if useCustomInstructions {
                viewModel.refreshSession()
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") {
                viewModel.dismissError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }

    // MARK: - View Components

    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: Spacing.medium) {
                    ForEach(viewModel.messages) { message in
                        MessageView(message: message)
                            .id(message.id)
                    }

                    // Empty spacer for bottom padding
                    Rectangle()
                        .fill(.clear)
                        .frame(height: 1)
                        .id("bottom")
                }
                .padding(.vertical)
            }
#if os(iOS)
            .scrollDismissesKeyboard(.interactively)
#endif
            .scrollPosition(id: $scrollID, anchor: .bottom)
            .onChange(of: viewModel.messages.count) { _, _ in
                if let lastMessage = viewModel.messages.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: viewModel.streamingContent) { _, _ in
                if let lastMessage = viewModel.messages.last {
                    withAnimation(.easeOut(duration: 0.1)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
        .defaultScrollAnchor(.bottom)
    }
}

#Preview {
    NavigationStack {
        ChatView(viewModel: .constant(ChatViewModel()))
    }
}
```

**Step 4: Update ChatInputView to remove ChatViewModel dependency**

Replace contents of `Prysm/Views/Components/ChatInputView.swift`:

```swift
//
//  ChatInputView.swift
//  Prysm
//

import SwiftUI

struct ChatInputView: View {
    @Binding var messageText: String
    let isLoading: Bool
    @FocusState.Binding var isTextFieldFocused: Bool
    let onSend: (String) -> Void
    @AppStorage("useCustomInstructions") private var useCustomInstructions = false

    var body: some View {
        VStack(spacing: 0) {
            if useCustomInstructions {
                HStack(spacing: Spacing.xSmall) {
                    Image(systemName: "wand.and.stars")
                        .font(.caption2)
                    Text("Custom instructions active")
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.bottom, 4)
            }

            HStack(alignment: .bottom, spacing: Spacing.small) {
                HStack(alignment: .bottom, spacing: Spacing.small) {
                    TextField("Type your message...", text: $messageText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .lineLimit(1...5)
                        .focused($isTextFieldFocused)
                        .onSubmit {
                            sendMessage()
                        }
#if os(iOS)
                        .submitLabel(.send)
#endif

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.secondary : Color.accentColor)
                    }
                    .buttonStyle(.plain)
                    .disabled(
                        messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        isLoading
                    )
                }
                .padding(Spacing.small)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.pill))
            }
            .padding()
        }
    }

    private func sendMessage() {
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }

        messageText = ""
        isTextFieldFocused = true
        onSend(trimmedMessage)
    }
}
```

**Step 5: Remove the old ChatMessage model (it's replaced by LLMMessage)**

Delete `Prysm/Models/ChatMessage.swift` — its functionality is now in `LLMMessage`.

**Step 6: Verify it compiles**

Run: `cd /Users/andrewbierman/Code/Prysm && xcodebuild -scheme Prysm -destination 'platform=macOS' build 2>&1 | tail -10`
Expected: BUILD SUCCEEDED (there may be warnings about unused ContentViewModel transcript references — handled in Task 8)

**Step 7: Commit**

```bash
git add -A
git commit -m "refactor: ChatView and components to use LLMMessage instead of Transcript"
```

---

## Task 7: Add Remote API Configuration UI

**Files:**
- Create: `Prysm/Views/RemoteAPISettingsView.swift`
- Modify: `Prysm/Views/SettingsView.swift` (add link to remote API settings)
- Modify: `Prysm/Views/LanguagesView.swift` (add remote model option)

**Step 1: Create RemoteAPISettingsView**

```swift
//
//  RemoteAPISettingsView.swift
//  Prysm
//

import SwiftUI

struct RemoteAPISettingsView: View {
    @Binding var viewModel: ChatViewModel
    @State private var baseURL: String = ""
    @State private var apiKey: String = ""
    @State private var modelName: String = ""
    @State private var isTestingConnection: Bool = false
    @State private var connectionStatus: ConnectionStatus?

    enum ConnectionStatus {
        case success(String)
        case failure(String)
    }

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("Endpoint URL")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("http://localhost:1234", text: $baseURL)
                        .textFieldStyle(.plain)
#if os(iOS)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
#endif
                }

                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("API Key (optional for local servers)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    SecureField("sk-...", text: $apiKey)
                        .textFieldStyle(.plain)
                }

                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("Model Name")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("default", text: $modelName)
                        .textFieldStyle(.plain)
#if os(iOS)
                        .autocapitalization(.none)
#endif
                }
            } header: {
                Text("Connection")
            } footer: {
                Text("Works with LM Studio, Ollama, OpenAI, and any OpenAI-compatible API.")
            }

            Section {
                Button {
                    testConnection()
                } label: {
                    HStack {
                        Label("Test Connection", systemImage: "antenna.radiowaves.left.and.right")
                        Spacer()
                        if isTestingConnection {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                .disabled(baseURL.isEmpty || isTestingConnection)

                if let status = connectionStatus {
                    switch status {
                    case .success(let msg):
                        Label(msg, systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    case .failure(let msg):
                        Label(msg, systemImage: "xmark.circle.fill")
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }

            Section {
                Button("Save Configuration") {
                    saveConfig()
                }
                .disabled(baseURL.isEmpty)
            }

            Section {
                VStack(alignment: .leading, spacing: Spacing.medium) {
                    Label("Quick Setup Guides", systemImage: "book")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("LM Studio")
                            .font(.subheadline)
                            .bold()
                        Text("1. Open LM Studio and load a model\n2. Start the local server (default: http://localhost:1234)\n3. Enter the URL above")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Ollama")
                            .font(.subheadline)
                            .bold()
                        Text("1. Run: ollama serve\n2. URL: http://localhost:11434\n3. Model name: the model you pulled (e.g., llama3)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Remote API")
#if os(iOS)
        .navigationBarTitleDisplayMode(.large)
#else
        .formStyle(.grouped)
#endif
        .onAppear {
            baseURL = viewModel.remoteProvider.config.baseURL
            apiKey = viewModel.remoteProvider.config.apiKey
            modelName = viewModel.remoteProvider.config.modelName
        }
    }

    private func saveConfig() {
        let config = RemoteProviderConfig(
            baseURL: baseURL,
            apiKey: apiKey,
            modelName: modelName.isEmpty ? "default" : modelName
        )
        viewModel.updateRemoteConfig(config)
    }

    private func testConnection() {
        isTestingConnection = true
        connectionStatus = nil

        // Save first so the provider has the latest config
        saveConfig()

        Task {
            do {
                guard let url = URL(string: "\(baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/")))/v1/models") else {
                    await MainActor.run {
                        connectionStatus = .failure("Invalid URL")
                        isTestingConnection = false
                    }
                    return
                }

                var request = URLRequest(url: url)
                request.timeoutInterval = 10
                if !apiKey.isEmpty {
                    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                }

                let (data, response) = try await URLSession.shared.data(for: request)

                await MainActor.run {
                    if let httpResponse = response as? HTTPURLResponse,
                       (200...299).contains(httpResponse.statusCode) {
                        // Try to parse model list
                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let models = json["data"] as? [[String: Any]] {
                            connectionStatus = .success("Connected! \(models.count) model(s) available.")
                        } else {
                            connectionStatus = .success("Connected successfully!")
                        }
                    } else {
                        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                        connectionStatus = .failure("HTTP \(statusCode)")
                    }
                    isTestingConnection = false
                }
            } catch {
                await MainActor.run {
                    connectionStatus = .failure(error.localizedDescription)
                    isTestingConnection = false
                }
            }
        }
    }
}
```

**Step 2: Add "Remote API" link to SettingsView**

In `Prysm/Views/SettingsView.swift`, add after the `chatSection` in the `body` Form:

```swift
// Add this section after chatSection in the Form
remoteAPISection
```

And add this computed property:

```swift
private var remoteAPISection: some View {
    Section("Remote API") {
        NavigationLink(destination: RemoteAPISettingsView(viewModel: /* pass binding */)) {
            Label("Configure Remote API", systemImage: "network")
        }

        HStack {
            Image(systemName: "info.circle")
                .foregroundStyle(.secondary)
            Text("Connect to LM Studio, Ollama, OpenAI, or any compatible API")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
```

Note: The exact binding mechanism depends on how `ChatViewModel` is passed through the app. The SettingsView will need a `@Binding var chatViewModel: ChatViewModel` or access via `@Environment`. Check how `PrysmApp.swift` and `AdaptiveNavigationView.swift` pass the view model and follow the same pattern.

**Step 3: Update LanguagesView to show Remote option**

In `Prysm/Views/LanguagesView.swift`, in `checkAvailableModels()`, add after the existing models:

```swift
// Always show remote option
models.append(
    LanguageModelInfo(
        id: "remote",
        name: "Remote API",
        description: "Connect to LM Studio, Ollama, OpenAI, or any compatible server",
        capabilities: ["Custom models", "Any size model", "OpenAI compatible"],
        icon: "network",
        accentColor: .purple
    )
)
```

**Step 4: Verify it compiles**

Run: `cd /Users/andrewbierman/Code/Prysm && xcodebuild -scheme Prysm -destination 'platform=macOS' build 2>&1 | tail -10`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: add Remote API settings UI with connection testing and quick setup guides"
```

---

## Task 8: Wire Up PrysmApp Entry Point and Fix Remaining References

Check `PrysmApp.swift` and `AdaptiveNavigationView.swift` to ensure the ChatViewModel binding flows correctly to all views, and fix any remaining references to the old `session.transcript` or `ChatMessage` type.

**Files:**
- Modify: `Prysm/PrysmApp.swift` (if needed)
- Modify: `Prysm/Views/AdaptiveNavigationView.swift` (if needed)
- Modify: Any file still referencing `Transcript`, `session.transcript`, or old `ChatMessage`

**Step 1: Search for remaining broken references**

Run: `grep -rn "session\.transcript\|Transcript\.Entry\|ChatMessage\|LanguageModelFeedback" Prysm/Views/ Prysm/ViewModels/ Prysm/Models/`

Fix each file that still references old types. Key things to check:
- `AdaptiveNavigationView.swift` — make sure ChatViewModel is passed correctly
- `PrysmApp.swift` — make sure the `@State var chatViewModel` is created and bound
- Remove `ChatMessage.swift` if not already deleted
- Remove `Prysm/Extensions/Transcript+TokenCounting.swift` (no longer needed for remote; keep if on-device still uses it internally)
- `Prysm/Models/FoundationModelsError.swift` — keep as-is (still used by OnDeviceProvider)

**Step 2: Verify full build**

Run: `cd /Users/andrewbierman/Code/Prysm && xcodebuild -scheme Prysm -destination 'platform=macOS' build 2>&1 | tail -10`
Expected: BUILD SUCCEEDED with 0 errors

**Step 3: Commit**

```bash
git add -A
git commit -m "fix: wire up providers and fix all remaining type references"
```

---

## Task 9: Add Network Permission (Info.plist / Entitlements)

**Files:**
- Modify: `Prysm/Info.plist` or Xcode project settings

**Step 1: Add App Transport Security exception for local servers**

Since LM Studio and Ollama run on localhost over HTTP (not HTTPS), we need to allow arbitrary loads for localhost. Add to Info.plist:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>localhost</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

For macOS, also ensure the app has the `com.apple.security.network.client` entitlement (outgoing network connections):

```xml
<key>com.apple.security.network.client</key>
<true/>
```

**Step 2: Add `NSLocalNetworkUsageDescription` for iOS (if targeting local network)**

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>Prysm connects to local AI servers like LM Studio and Ollama for language model inference.</string>
```

**Step 3: Verify build still succeeds**

Run: `cd /Users/andrewbierman/Code/Prysm && xcodebuild -scheme Prysm -destination 'platform=macOS' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add -A
git commit -m "feat: add network permissions for local server connections"
```

---

## Task 10: Update Tests

**Files:**
- Modify: `PrysmTests/ChatViewModelTests.swift`

**Step 1: Update tests to use new ChatViewModel API**

The tests need to be updated since `ChatViewModel` no longer exposes `session.transcript`. Key changes:
- Replace `session.transcript` references with `messages`
- Test `sendMessage` adds to `messages` array
- Test `clearChat` empties `messages`
- Test `isUsingRemote` flag switching
- Test `updateRemoteConfig` persists config

Example test updates:

```swift
@Test
func testInitialization() {
    let viewModel = ChatViewModel()
    #expect(viewModel.messages.isEmpty)
    #expect(!viewModel.isLoading)
    #expect(!viewModel.isStreaming)
    #expect(viewModel.errorMessage == nil)
}

@Test
func testClearChat() {
    let viewModel = ChatViewModel()
    // Add a mock message
    viewModel.messages.append(LLMMessage(role: .user, content: "Hello"))
    viewModel.clearChat()
    #expect(viewModel.messages.isEmpty)
}

@Test
func testRemoteConfigPersistence() {
    let viewModel = ChatViewModel()
    let config = RemoteProviderConfig(
        baseURL: "http://localhost:1234",
        apiKey: "test-key",
        modelName: "test-model"
    )
    viewModel.updateRemoteConfig(config)
    #expect(viewModel.remoteProvider.config.baseURL == "http://localhost:1234")
    #expect(viewModel.remoteProvider.config.modelName == "test-model")
}
```

**Step 2: Run tests**

Run: `cd /Users/andrewbierman/Code/Prysm && xcodebuild -scheme Prysm -destination 'platform=macOS' test 2>&1 | tail -20`
Expected: All tests pass

**Step 3: Commit**

```bash
git add PrysmTests/
git commit -m "test: update ChatViewModel tests for provider-based architecture"
```

---

## Task 11: Manual Testing Checklist

Before considering this feature complete, verify:

- [ ] App launches without crash
- [ ] On-device chat works as before (type message, get streaming response)
- [ ] Settings > Remote API shows the configuration form
- [ ] Can enter LM Studio URL (http://localhost:1234) and test connection
- [ ] Model selection shows "Remote API" option alongside "On-Device Model"
- [ ] Selecting "Remote API" in model picker switches to remote provider
- [ ] Sending a message with remote provider streams response correctly
- [ ] Switching back to on-device model works
- [ ] Clear chat works in both modes
- [ ] Custom instructions work with remote provider
- [ ] API key is saved to Keychain (not visible in UserDefaults)
- [ ] Error handling: shows clear error when remote server is unreachable
- [ ] Generation options (temperature, etc.) are sent to remote API

---

## Summary of New/Modified Files

### New Files (4)
| File | Purpose |
|------|---------|
| `Prysm/Services/LLMProvider.swift` | Protocol + LLMMessage + GenerationConfig |
| `Prysm/Services/OnDeviceProvider.swift` | FoundationModels wrapper |
| `Prysm/Services/RemoteProvider.swift` | OpenAI-compatible HTTP client with SSE |
| `Prysm/Services/KeychainHelper.swift` | Secure credential storage |
| `Prysm/Views/RemoteAPISettingsView.swift` | Remote API configuration UI |

### Modified Files (7)
| File | Changes |
|------|---------|
| `Prysm/ViewModels/ChatViewModel.swift` | Use LLMProvider, own message history |
| `Prysm/Views/ChatView.swift` | Iterate `messages` instead of `transcript` |
| `Prysm/Views/TranscriptEntryView.swift` | Renamed/simplified to MessageView |
| `Prysm/Views/Components/MessageBubbleView.swift` | Simplified, no ViewModel dependency |
| `Prysm/Views/Components/ChatInputView.swift` | Callback-based, no ViewModel dependency |
| `Prysm/Views/LanguagesView.swift` | Add "Remote API" model option |
| `Prysm/Views/SettingsView.swift` | Add Remote API section |

### Deleted Files (1)
| File | Reason |
|------|--------|
| `Prysm/Models/ChatMessage.swift` | Replaced by LLMMessage |
