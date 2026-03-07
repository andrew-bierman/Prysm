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
