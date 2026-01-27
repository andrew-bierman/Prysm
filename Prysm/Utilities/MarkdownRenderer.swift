//
//  MarkdownRenderer.swift
//  Prysm
//
//  Device-capable markdown rendering with native/fallback support
//

import SwiftUI
import Foundation

enum MarkdownRenderer {

    static func supportsNativeMarkdown() -> Bool {
        if #available(iOS 15.0, macOS 12.0, *) {
            return true
        }
        return false
    }

    @MainActor
    static func renderMarkdown(_ markdown: String) -> AttributedString {
        if supportsNativeMarkdown() {
            return renderMarkdownNatively(markdown)
        } else {
            return AttributedString(stripMarkdown(markdown))
        }
    }

    @available(iOS 15.0, macOS 12.0, *)
    static func renderMarkdownNatively(_ markdown: String) -> AttributedString {
        do {
            return try AttributedString(markdown: markdown, options: .init(allowsExtendedAttributes: true, interpretedSyntax: .full))
        } catch {
            return AttributedString(markdown)
        }
    }

    static func parseMarkdownManually(_ markdown: String) -> AttributedString {
        return AttributedString(stripMarkdown(markdown))
    }
}

extension MarkdownRenderer {
    static func stripMarkdown(_ markdown: String) -> String {
        var result = markdown

        let patterns: [(String, String)] = [
            ("\\*\\*(.+?)\\*\\*", "$1"),
            ("\\*(.+?)\\*", "$1"),
            ("`(.+?)`", "$1"),
            ("\\[([^[\\]]+?)\\]\\([^(]+?\\)", "$1"),
            ("#{1,6}\\s+(.+)", "$1"),
            ("^\\s*[-*+]\\s+", ""),
            ("^\\s*\\d+\\.\\s+", "")
        ]

        for (pattern, replacement) in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) {
                let range = NSRange(result.startIndex..., in: result)
                result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: replacement)
            }
        }

        return result
    }
}
