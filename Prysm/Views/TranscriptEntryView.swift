//
//  TranscriptEntryView.swift
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
