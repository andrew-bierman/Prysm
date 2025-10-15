import SwiftUI
import SwiftData

struct SimpleChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorScheme) private var colorScheme

    @State private var viewModel: SimpleChatViewModel
    @State private var scrollViewID = UUID()
    @State private var currentMessage: String = ""
    @FocusState private var isInputFocused: Bool

    #if os(iOS)
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    init(modelContext: ModelContext) {
        self._viewModel = State(initialValue: SimpleChatViewModel(modelContext: modelContext))
    }

    var body: some View {
        Group {
            #if os(macOS)
            macOSLayout
            #elseif os(visionOS)
            visionOSLayout
            #else
            iOSLayout
            #endif
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.messages.count)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isResponding)
        .onAppear {
            // Auto-focus input on appear for better UX
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isInputFocused = true
            }
        }
    }

    // MARK: - Platform-Specific Layouts

    #if os(macOS)
    private var macOSLayout: some View {
        NavigationSplitView {
            // Sidebar for conversation list (future feature)
            VStack {
                Text("Conversations")
                    .font(.headline)
                    .padding()
                Spacer()
            }
            .frame(minWidth: 200, idealWidth: 250)
        } detail: {
            chatContent
                .navigationTitle("Prism Chat")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        clearButton
                    }
                }
        }
    }
    #endif

    #if os(visionOS)
    private var visionOSLayout: some View {
        NavigationStack {
            chatContent
                .navigationTitle("Prism Chat")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        clearButton
                    }
                }
        }
        .background(.regularMaterial, in: .rect(cornerRadius: 16))
    }
    #endif

    #if os(iOS)
    private var iOSLayout: some View {
        NavigationStack {
            chatContent
                .navigationTitle("Prism Chat")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        clearButton
                    }
                }
        }
    }
    #endif

    // MARK: - Main Chat Content

    private var chatContent: some View {
        VStack(spacing: 0) {
            if viewModel.hasMessages {
                messagesScrollView
            } else {
                emptyStateView
            }

            inputArea
        }
        .background(backgroundView)
    }

    // MARK: - Messages List

    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages, id: \.id) { message in
                        SimpleMessageBubble(message: message, viewModel: viewModel)
                            .id(message.id)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }

                    if viewModel.isResponding {
                        SimpleTypingIndicator()
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.messages.count) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: viewModel.isResponding) { _, _ in
                if viewModel.isResponding {
                    scrollToBottom(proxy: proxy)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("Welcome to Prism")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Start a conversation by typing a message below")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Quick start suggestions
            VStack(spacing: 8) {
                Text("Try asking:")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                VStack(spacing: 4) {
                    suggestionButton("Hello, how can you help me?")
                    suggestionButton("What are your capabilities?")
                    suggestionButton("Can you help me with coding?")
                }
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel("Empty chat state")
        .accessibilityHint("No messages yet. Use the input field below to start a conversation")
    }

    private func suggestionButton(_ text: String) -> some View {
        Button {
            currentMessage = text
            Task {
                await viewModel.sendMessage(currentMessage)
                currentMessage = ""
            }
        } label: {
            Text(text)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.quaternary, in: .capsule)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Input Area

    private var inputArea: some View {
        VStack(spacing: 0) {
            if let error = viewModel.currentError {
                errorView(error)
            }

            HStack(spacing: 12) {
                inputField
                sendButton
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(inputBackgroundView)
        }
    }

    private var inputField: some View {
        TextField("Type a message...", text: $currentMessage, axis: .vertical)
            .textFieldStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial, in: .rect(cornerRadius: 20))
            .focused($isInputFocused)
            .disabled(viewModel.isResponding)
            .onSubmit {
                if canSendMessage {
                    Task {
                        await viewModel.sendMessage(currentMessage)
                        currentMessage = ""
                    }
                }
            }
            .accessibilityLabel("Message input")
            .accessibilityHint("Type your message here. Press return to send")
    }

    private var sendButton: some View {
        Button {
            Task {
                if viewModel.isResponding {
                    viewModel.cancelCurrentOperation()
                } else {
                    await viewModel.sendMessage(currentMessage)
                    currentMessage = ""
                }
            }
        } label: {
            Image(systemName: viewModel.isResponding ? "stop.circle.fill" : "arrow.up.circle.fill")
                .font(.title2)
                .foregroundStyle(canSendMessage ? .blue : .secondary)
        }
        .disabled(!canSendMessage && !viewModel.isResponding)
        .accessibilityLabel(viewModel.isResponding ? "Stop generation" : "Send message")
        .accessibilityHint(viewModel.isResponding ? "Tap to stop the current response" : "Send your message")
        .scaleEffect(canSendMessage ? 1.0 : 0.8)
        .animation(.spring(response: 0.3), value: canSendMessage)
    }

    // MARK: - Background Views

    private var backgroundView: some View {
        Group {
            #if os(macOS)
            Color.clear
            #elseif os(visionOS)
            Color.clear
            #else
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemBackground).opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            #endif
        }
    }

    private var inputBackgroundView: some View {
        Group {
            #if os(iOS) || os(visionOS)
            .ultraThinMaterial
            #else
            Color(.controlBackgroundColor)
            #endif
        }
    }

    // MARK: - Error View

    private func errorView(_ error: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)

            Text(error)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Button("Dismiss") {
                viewModel.clearError()
            }
            .font(.caption)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.orange.opacity(0.1), in: .rect(cornerRadius: 8))
        .padding(.horizontal, 16)
    }

    // MARK: - Toolbar Items

    private var clearButton: some View {
        Button {
            withAnimation {
                Task {
                    await viewModel.clearSession()
                }
            }
        } label: {
            Label("Clear Chat", systemImage: "trash")
        }
        .disabled(!viewModel.hasMessages)
        .accessibilityLabel("Clear all messages")
        .accessibilityHint("Remove all messages from the current conversation")
    }

    // MARK: - Computed Properties

    private var canSendMessage: Bool {
        !currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !viewModel.isResponding &&
        viewModel.isModelAvailable
    }

    // MARK: - Helper Methods

    private func scrollToBottom<Content: View>(proxy: ScrollViewReader<Content>) {
        guard let lastMessage = viewModel.lastMessage else { return }

        withAnimation(.easeOut(duration: 0.3)) {
            proxy.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
}

// MARK: - Simple Message Bubble Component

struct SimpleMessageBubble: View {
    let message: Message
    let viewModel: SimpleChatViewModel

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 50)
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                HStack(spacing: 8) {
                    if message.role != .user {
                        Image(systemName: message.role.iconName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text(message.role.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                messageContent
                    .contextMenu {
                        contextMenuItems
                    }
            }
            .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)

            if message.role != .user {
                Spacer(minLength: 50)
            }
        }
    }

    private var messageContent: some View {
        Text(message.content)
            .font(.body)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                message.role == .user ? userBubbleBackground : assistantBubbleBackground,
                in: .rect(cornerRadius: 16)
            )
            .foregroundStyle(message.role == .user ? .white : .primary)
            .accessibilityLabel("\(message.role.displayName) message")
            .accessibilityValue(message.content)
    }

    private var userBubbleBackground: some ShapeStyle {
        .blue
    }

    private var assistantBubbleBackground: some ShapeStyle {
        #if os(macOS)
        .quaternary
        #else
        .regularMaterial
        #endif
    }

    private var contextMenuItems: some View {
        Group {
            Button {
                #if os(macOS)
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(message.content, forType: .string)
                #else
                UIPasteboard.general.string = message.content
                #endif
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }

            Button(role: .destructive) {
                if let index = viewModel.messages.firstIndex(where: { $0.id == message.id }) {
                    viewModel.deleteMessage(at: index)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }

            Button {
                Task {
                    do {
                        let exportData = try await viewModel.exportConversation(format: .plainText)
                        if let exportText = String(data: exportData, encoding: .utf8) {
                            #if os(macOS)
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(exportText, forType: .string)
                            #else
                            UIPasteboard.general.string = exportText
                            #endif
                        }
                    } catch {
                        // Handle export error silently
                    }
                }
            } label: {
                Label("Export All", systemImage: "square.and.arrow.up")
            }
        }
    }
}

// MARK: - Typing Indicator

struct SimpleTypingIndicator: View {
    @State private var animationPhase = 0.0

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Prism")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
            }

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(.secondary)
                        .frame(width: 6, height: 6)
                        .scaleEffect(animationPhase == Double(index) ? 1.2 : 0.8)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: animationPhase
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.quaternary, in: .rect(cornerRadius: 16))

            Spacer(minLength: 50)
        }
        .onAppear {
            animationPhase = 1.0
        }
        .accessibilityLabel("Prism is typing")
    }
}

// MARK: - Preview

#Preview("Simple Chat with Messages") {
    let container = try! ModelContainer(
        for: Message.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let context = container.mainContext

    // Add sample messages
    let userMessage = Message(content: "Hello, how are you today?", role: .user)
    let assistantMessage = Message(content: "Hello! I'm doing well, thank you for asking. I'm here to help you with any questions or tasks you might have. How can I assist you today?", role: .assistant)

    context.insert(userMessage)
    context.insert(assistantMessage)

    return SimpleChatView(modelContext: context)
        .modelContainer(container)
}

#Preview("Simple Empty Chat") {
    let container = try! ModelContainer(
        for: Message.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    return SimpleChatView(modelContext: container.mainContext)
        .modelContainer(container)
}