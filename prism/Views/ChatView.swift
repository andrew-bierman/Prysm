//
//  ChatView.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import SwiftUI
import FoundationModels

struct ChatView: View {
    @Binding var viewModel: ChatViewModel
    @State private var scrollID: String?
    @State private var messageText = ""
    @State private var showInstructionsSheet = false
    @State private var showFeedbackSheet = false
    @State private var selectedEntryForFeedback: Transcript.Entry?
    @State private var showTokenCount = false
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
                isTextFieldFocused: $isTextFieldFocused
            )
        }
        .environment(viewModel)
        .navigationTitle("Chat")
#if os(iOS)
        .navigationBarTitleDisplayMode(.large)
#endif
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if showTokenCount {
                    Text("\(viewModel.session.transcript.estimatedTokenCount) tokens")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button(action: { showInstructionsSheet = true }) {
                    Label("Instructions", systemImage: useCustomInstructions ? "doc.text.fill" : "doc.text")
                        .foregroundStyle(useCustomInstructions ? Color.accentColor : Color.primary)
                }
                .help("Customize AI behavior")

                Menu {
                    Button(action: { showTokenCount.toggle() }) {
                        Label(showTokenCount ? "Hide Token Count" : "Show Token Count", systemImage: "number")
                    }
                    Divider()
                    Button("Clear Chat", role: .destructive) {
                        viewModel.clearChat()
                    }
                    .disabled(viewModel.session.transcript.isEmpty)
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
            // Auto-focus when chat appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }

    // MARK: - View Components

    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.session.transcript) { entry in
                        TranscriptEntryView(entry: entry)
                            .id(entry.id)
                    }

                    if viewModel.isSummarizing {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Summarizing conversation...")
                                .font(.caption)
                                .foregroundStyle(.orange)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .id("summarizing")
                    }

                    if viewModel.isApplyingWindow {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Optimizing conversation history...")
                                .font(.caption)
                                .foregroundStyle(.blue)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .id("windowing")
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
            .onChange(of: viewModel.session.transcript.count) { _, _ in
                if let lastEntry = viewModel.session.transcript.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(lastEntry.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: viewModel.isSummarizing) { _, isSummarizing in
                if isSummarizing {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo("summarizing", anchor: .bottom)
                    }
                }
            }
            .onChange(of: viewModel.isApplyingWindow) { _, isApplyingWindow in
                if isApplyingWindow {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo("windowing", anchor: .bottom)
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