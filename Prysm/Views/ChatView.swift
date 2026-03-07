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

    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: Spacing.medium) {
                    ForEach(viewModel.messages) { message in
                        MessageView(message: message)
                            .id(message.id)
                    }

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
