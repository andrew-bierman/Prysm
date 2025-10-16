//
//  MessageBubbleView.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import SwiftUI
import FoundationModels

struct MessageBubbleView: View {
    let message: ChatMessage
    @Environment(ChatViewModel.self) var viewModel

    var body: some View {
        HStack {
            if message.isFromUser {
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
        VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: Spacing.xSmall) {
            Text(message.content)
                .textSelection(.enabled)
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small)
            .background(
                message.isFromUser ?
                Color.accentColor : Color.gray.opacity(0.2)
            )
            .foregroundStyle(
                message.isFromUser ? .white : .primary
            )
            .clipShape(RoundedRectangle(cornerRadius: Spacing.CornerRadius.large))

            HStack(spacing: Spacing.small) {
                Text(message.timestamp, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                if !message.isFromUser, let entryID = message.entryID {
                    // Feedback buttons for AI responses
                    HStack(spacing: Spacing.xSmall) {
                        if let sentiment = viewModel.getFeedback(for: entryID) {
                            Image(systemName: sentiment == .positive ? "hand.thumbsup.fill" : "hand.thumbsdown.fill")
                                .font(.caption2)
                                .foregroundStyle(sentiment == .positive ? .green : .red)
                        } else {
                            Button {
                                viewModel.submitFeedback(for: entryID, sentiment: .positive)
                            } label: {
                                Image(systemName: "hand.thumbsup")
                                    .font(.caption2)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.secondary)

                            Button {
                                viewModel.submitFeedback(for: entryID, sentiment: .negative)
                            } label: {
                                Image(systemName: "hand.thumbsdown")
                                    .font(.caption2)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}