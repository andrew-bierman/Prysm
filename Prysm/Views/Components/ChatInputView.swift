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
