//
//  MarkdownTextView.swift
//  Prism
//
//  Renders markdown formatted text with proper styling
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct MarkdownTextView: View {
    let text: String
    let isFromUser: Bool

    var body: some View {
        Text(attributedMarkdown)
            .textSelection(.enabled)
    }

    private var attributedMarkdown: AttributedString {
        do {
            var attributed = try AttributedString(
                markdown: text,
                options: AttributedString.MarkdownParsingOptions(
                    interpretedSyntax: .inlineOnlyPreservingWhitespace
                )
            )

            // Apply basic styling
            attributed.foregroundColor = isFromUser ? .primary : .primary

            return attributed
        } catch {
            // Fallback to plain text if markdown parsing fails
            return AttributedString(text)
        }
    }
}

// Code block view for multiline code
struct CodeBlockView: View {
    let code: String
    let language: String?
    @State private var isCopied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                if let language = language {
                    Text(language)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: copyCode) {
                    Label(isCopied ? "Copied!" : "Copy", systemImage: isCopied ? "checkmark" : "doc.on.doc")
                        .font(.caption)
                        .foregroundStyle(isCopied ? .green : .accentColor)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray5))

            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .padding(12)
            }
            .background(Color(.systemGray6))
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
    }

    private func copyCode() {
#if os(iOS)
        UIPasteboard.general.string = code
#elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(code, forType: .string)
#endif

        isCopied = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isCopied = false
        }
    }
}

// Enhanced message content view that handles markdown
struct EnhancedMessageContentView: View {
    let content: String
    let isFromUser: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(parseContent(), id: \.id) { component in
                component.view
            }
        }
    }

    private struct ContentComponent: Identifiable {
        let id = UUID()
        let view: AnyView
    }

    private func parseContent() -> [ContentComponent] {
        var components: [ContentComponent] = []
        let lines = content.split(separator: "\n", omittingEmptySubsequences: false)
        var currentCodeBlock: [String] = []
        var currentLanguage: String? = nil
        var inCodeBlock = false
        var currentText = ""

        for line in lines {
            let lineStr = String(line)

            // Check for code block markers
            if lineStr.hasPrefix("```") {
                if inCodeBlock {
                    // End of code block
                    if !currentCodeBlock.isEmpty {
                        let code = currentCodeBlock.joined(separator: "\n")
                        components.append(ContentComponent(
                            view: AnyView(CodeBlockView(code: code, language: currentLanguage))
                        ))
                    }
                    currentCodeBlock = []
                    currentLanguage = nil
                    inCodeBlock = false
                } else {
                    // Start of code block
                    if !currentText.isEmpty {
                        components.append(ContentComponent(
                            view: AnyView(MarkdownTextView(text: currentText, isFromUser: isFromUser))
                        ))
                        currentText = ""
                    }
                    inCodeBlock = true
                    // Extract language if specified
                    let language = lineStr.dropFirst(3).trimmingCharacters(in: .whitespaces)
                    currentLanguage = language.isEmpty ? nil : language
                }
            } else if inCodeBlock {
                currentCodeBlock.append(lineStr)
            } else {
                currentText += lineStr + "\n"
            }
        }

        // Handle remaining text
        if !currentText.isEmpty {
            components.append(ContentComponent(
                view: AnyView(MarkdownTextView(text: currentText.trimmingCharacters(in: .newlines), isFromUser: isFromUser))
            ))
        }

        // Handle unclosed code block
        if !currentCodeBlock.isEmpty {
            let code = currentCodeBlock.joined(separator: "\n")
            components.append(ContentComponent(
                view: AnyView(CodeBlockView(code: code, language: currentLanguage))
            ))
        }

        return components
    }
}