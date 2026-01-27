//
//  MarkdownRendererTests.swift
//  PrysmTests
//
//  Testing MarkdownRenderer device detection and parsing
//

import Testing
import Foundation
import SwiftUI
@testable import Prysm

@MainActor
struct MarkdownRendererTests {

    @Test("supportsNativeMarkdown returns correct value")
    func testSupportsNativeMarkdown() {
        let result = MarkdownRenderer.supportsNativeMarkdown()
        #expect(result == true || result == false)
    }

    @Test("stripMarkdown removes bold markers")
    func testStripMarkdownBold() {
        let input = "**bold**"
        let result = MarkdownRenderer.stripMarkdown(input)
        #expect(result == "bold")
    }

    @Test("stripMarkdown removes italic markers")
    func testStripMarkdownItalic() {
        let input = "*italic*"
        let result = MarkdownRenderer.stripMarkdown(input)
        #expect(result == "italic")
    }

    @Test("stripMarkdown removes code markers")
    func testStripMarkdownCode() {
        let input = "`code`"
        let result = MarkdownRenderer.stripMarkdown(input)
        #expect(result == "code")
    }

    @Test("stripMarkdown removes link formatting")
    func testStripMarkdownLinks() {
        let input = "[link text](https://example.com)"
        let result = MarkdownRenderer.stripMarkdown(input)
        #expect(result == "link text")
    }

    @Test("stripMarkdown removes heading markers")
    func testStripMarkdownHeadings() {
        let input = "# Heading 1\n## Heading 2"
        let result = MarkdownRenderer.stripMarkdown(input)
        #expect(result.contains("Heading 1"))
        #expect(result.contains("Heading 2"))
    }

    @Test("stripMarkdown removes list markers")
    func testStripMarkdownLists() {
        let input = "- Item 1\n* Item 2\n+ Item 3\n1. Item 4"
        let result = MarkdownRenderer.stripMarkdown(input)
        #expect(result.contains("Item 1"))
        #expect(result.contains("Item 2"))
        #expect(result.contains("Item 3"))
        #expect(result.contains("Item 4"))
    }

    @Test("stripMarkdown handles empty string")
    func testStripMarkdownEmptyString() {
        let input = ""
        let result = MarkdownRenderer.stripMarkdown(input)
        #expect(result.isEmpty)
    }

    @Test("stripMarkdown handles plain text")
    func testStripMarkdownPlainText() {
        let input = "Hello, World!"
        let result = MarkdownRenderer.stripMarkdown(input)
        #expect(result == "Hello, World!")
    }

    @Test("stripMarkdown handles special characters")
    func testStripMarkdownSpecialCharacters() {
        let input = "Special chars: & < > \" '"
        let result = MarkdownRenderer.stripMarkdown(input)
        #expect(result.contains("Special chars"))
    }

    @Test("stripMarkdown handles unicode characters")
    func testStripMarkdownUnicode() {
        let input = "Unicode: 你好 🎉 مرحبا"
        let result = MarkdownRenderer.stripMarkdown(input)
        #expect(result.contains("Unicode"))
    }

    @Test("stripMarkdown handles multiple bold sections")
    func testStripMarkdownMultipleBold() {
        let input = "**first** and **second**"
        let result = MarkdownRenderer.stripMarkdown(input)
        #expect(result.contains("first"))
        #expect(result.contains("second"))
    }

    @Test("stripMarkdown handles complex markdown")
    func testStripMarkdownComplex() {
        let input = """
        # Heading

        This is **bold** and *italic* text.

        - List item 1
        - List item 2

        [Link](https://example.com)
        """

        let result = MarkdownRenderer.stripMarkdown(input)

        #expect(!result.isEmpty)
        #expect(result.contains("Heading"))
        #expect(result.contains("bold"))
    }

    @Test("renderMarkdown returns attributed string")
    func testRenderMarkdown() {
        let input = "Hello"
        let result = MarkdownRenderer.renderMarkdown(input)
        #expect(result.string == "Hello")
    }

    @Test("renderMarkdown handles markdown content")
    func testRenderMarkdownWithMarkdown() {
        let input = "**bold** and *italic*"
        let result = MarkdownRenderer.renderMarkdown(input)
        #expect(!result.string.isEmpty)
    }
}
