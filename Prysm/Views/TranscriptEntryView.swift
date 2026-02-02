//
//  TranscriptEntryView.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import SwiftUI
import FoundationModels

struct TranscriptEntryView: View {
    let entry: Transcript.Entry

    var body: some View {
        switch entry {
        case .prompt(let prompt):
            if let text = extractText(from: prompt.segments), !text.isEmpty {
                MessageBubbleView(message: ChatMessage(content: text, isFromUser: true))
            }

        case .response(let response):
            if let text = extractText(from: response.segments), !text.isEmpty {
                MessageBubbleView(message: ChatMessage(content: text, isFromUser: false))
            }

        case .instructions:
            EmptyView()

        default:
            EmptyView()
        }
    }

    private func extractText(from segments: [Transcript.Segment]) -> String? {
        let text = segments.compactMap { segment in
            if case .text(let textSegment) = segment {
                return textSegment.content
            }
            return nil
        }.joined(separator: " ")

        return text.isEmpty ? nil : text
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
