//
//  ChatInputView.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import SwiftUI

struct ChatInputView: View {
    @Binding var messageText: String
    @Environment(ChatViewModel.self) var chatViewModel
    @FocusState.Binding var isTextFieldFocused: Bool
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
                TextField("Type your message...", text: $messageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...5)
                    .focused($isTextFieldFocused)
                    .padding(.horizontal, Spacing.medium)
                    .padding(.vertical, Spacing.small)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Spacing.CornerRadius.xLarge))
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
                        .foregroundStyle(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                }
                .buttonStyle(.plain)
                .disabled(
                    messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    chatViewModel.isLoading ||
                    chatViewModel.isSummarizing
                )
            }
            .padding()
        }
    }

    private func sendMessage() {
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }

        messageText = ""
        isTextFieldFocused = true

        Task {
            await chatViewModel.sendMessage(trimmedMessage)
        }
    }
}