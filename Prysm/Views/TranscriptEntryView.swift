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
            if let attributedText = extractAttributedText(from: prompt.segments), !attributedText.string.isEmpty {
                MessageBubbleView(message: ChatMessage(entryID: entry.id, content: attributedText, isFromUser: true))
            }

        case .response(let response):
            if let attributedText = extractAttributedText(from: response.segments), !attributedText.string.isEmpty {
                MessageBubbleView(message: ChatMessage(entryID: entry.id, content: attributedText, isFromUser: false))
            }

        case .instructions:
            EmptyView()

        default:
            EmptyView()
        }
    }

    private func extractAttributedText(from segments: [Transcript.Segment]) -> AttributedString? {
        let text = segments.compactMap { segment in
            if case .text(let textSegment) = segment {
                return textSegment.content
            }
            return nil
        }.joined(separator: " ")

        guard !text.isEmpty else { return nil }

        return MarkdownRenderer.renderMarkdown(text)
    }
}