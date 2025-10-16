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
        VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
            Text(message.content)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    message.isFromUser ?
                    Color.accentColor : Color.gray.opacity(0.2)
                )
                .foregroundStyle(
                    message.isFromUser ? .white : .primary
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))

            Text(message.timestamp, style: .relative)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}