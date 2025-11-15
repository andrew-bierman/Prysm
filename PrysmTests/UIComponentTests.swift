//
//  UIComponentTests.swift
//  PrismTests
//
//  Testing UI components and design constants
//

import Testing
import Foundation
import SwiftUI
@testable import Prysm

struct UIComponentTests {

    @Test("Spacing constants have correct values")
    func testSpacingConstants() {
        #expect(Spacing.xSmall == 4)
        #expect(Spacing.small == 8)
        #expect(Spacing.medium == 12)
        #expect(Spacing.large == 16)
        #expect(Spacing.xLarge == 24)
        #expect(Spacing.xxLarge == 32)
    }

    @Test("Corner radius constants have correct values")
    func testCornerRadiusConstants() {
        #expect(CornerRadius.small == 8)
        #expect(CornerRadius.medium == 12)
        #expect(CornerRadius.large == 16)
        #expect(CornerRadius.xLarge == 20)
        #expect(CornerRadius.pill == 24)
    }

    @Test("Tool categories have correct properties")
    func testToolCategories() {
        let categories: [ToolCategory] = [.productivity, .creativity, .research, .development, .communication]

        for category in categories {
            // Each category should have a non-empty raw value
            #expect(!category.rawValue.isEmpty)

            // Each category should have an icon
            #expect(!category.icon.isEmpty)

            // Each category should have a color
            let _ = category.color // Should not crash
        }

        // Test specific categories
        #expect(ToolCategory.productivity.rawValue == "Productivity")
        #expect(ToolCategory.creativity.rawValue == "Creativity")
        #expect(ToolCategory.research.rawValue == "Research")
        #expect(ToolCategory.development.rawValue == "Development")
        #expect(ToolCategory.communication.rawValue == "Communication")
    }

    @Test("Example types have correct properties")
    func testExampleTypes() {
        let examples: [ExampleType] = [.recipes, .bookRecommendations, .travelItinerary, .productReviews]

        for example in examples {
            #expect(!example.title.isEmpty)
            #expect(!example.subtitle.isEmpty)
            #expect(!example.icon.isEmpty)
            #expect(!example.prompt.isEmpty)
            let _ = example.accentColor // Should not crash
        }
    }

    @Test("Export formats have correct raw values")
    func testExportFormats() {
        #expect(ExportFormat.json.rawValue == "json")
        #expect(ExportFormat.markdown.rawValue == "markdown")
        #expect(ExportFormat.plainText.rawValue == "plainText")
        #expect(ExportFormat.csv.rawValue == "csv")
    }

    @Test("Message model initialization")
    func testMessageModel() {
        let now = Date()
        let message = Message(
            content: "Test message",
            isFromUser: true,
            timestamp: now,
            entryID: "test-id"
        )

        #expect(message.content == "Test message")
        #expect(message.isFromUser == true)
        #expect(message.timestamp == now)
        #expect(message.entryID == "test-id")

        // Test message without entryID
        let userMessage = Message(
            content: "User message",
            isFromUser: true,
            timestamp: now
        )
        #expect(userMessage.entryID == nil)
    }

    @Test("Tool item model properties")
    func testToolItemModel() {
        let tool = ToolItem(
            id: "testTool",
            name: "Test Tool",
            description: "A tool for testing",
            icon: "wrench",
            category: .development,
            isPremium: false
        )

        #expect(tool.id == "testTool")
        #expect(tool.name == "Test Tool")
        #expect(tool.description == "A tool for testing")
        #expect(tool.icon == "wrench")
        #expect(tool.category == .development)
        #expect(tool.isPremium == false)

        // Test premium tool
        let premiumTool = ToolItem(
            id: "premiumTool",
            name: "Premium Tool",
            description: "A premium tool",
            icon: "star",
            category: .creativity,
            isPremium: true
        )
        #expect(premiumTool.isPremium == true)
    }

    @Test("Language model info properties")
    func testLanguageModelInfo() {
        let model = LanguageModelInfo(
            id: "testModel",
            name: "Test Model",
            description: "A test language model",
            capabilities: ["Cap1", "Cap2", "Cap3"],
            icon: "brain",
            accentColor: .blue,
            isPremium: false
        )

        #expect(model.id == "testModel")
        #expect(model.name == "Test Model")
        #expect(model.description == "A test language model")
        #expect(model.capabilities.count == 3)
        #expect(model.capabilities.contains("Cap1"))
        #expect(model.icon == "brain")
        #expect(model.accentColor == .blue)
        #expect(model.isPremium == false)
    }
}

// MARK: - View Model Helpers Tests

extension UIComponentTests {

    @Test("Conversation title truncation")
    func testConversationTitleTruncation() {
        let viewModel = ChatViewModel()

        // Short message - no truncation
        viewModel.entries.append(Transcript.Entry(role: .user, content: "Hello"))
        #expect(viewModel.conversationTitle == "Hello")

        // Long message - should truncate
        viewModel.entries.removeAll()
        let longText = String(repeating: "A", count: 100)
        viewModel.entries.append(Transcript.Entry(role: .user, content: longText))
        let title = viewModel.conversationTitle
        #expect(title.count <= 50)
        #expect(title.hasSuffix("...") || title.count == 47) // 47 chars + "..."
    }

    @Test("Export format file extensions")
    func testExportFormatExtensions() {
        #expect(ExportFormat.json.fileExtension == "json")
        #expect(ExportFormat.markdown.fileExtension == "md")
        #expect(ExportFormat.plainText.fileExtension == "txt")
        #expect(ExportFormat.csv.fileExtension == "csv")
    }

    @Test("Tool category color associations")
    func testToolCategoryColors() {
        // Each category should return a valid Color
        let _ = ToolCategory.productivity.color
        let _ = ToolCategory.creativity.color
        let _ = ToolCategory.research.color
        let _ = ToolCategory.development.color
        let _ = ToolCategory.communication.color

        // Colors should be different for different categories
        // (We can't directly compare SwiftUI Colors in tests, but we can ensure they don't crash)
    }

    @Test("Example type color associations")
    func testExampleTypeColors() {
        // Each example type should return a valid Color
        let _ = ExampleType.recipes.accentColor
        let _ = ExampleType.bookRecommendations.accentColor
        let _ = ExampleType.travelItinerary.accentColor
        let _ = ExampleType.productReviews.accentColor
    }
}

// MARK: - Performance Tests

extension UIComponentTests {

    @Test("Large message list performance")
    func testLargeMessageListPerformance() {
        let viewModel = ChatViewModel()

        // Add many messages
        for i in 0..<200 {
            viewModel.entries.append(
                Transcript.Entry(
                    role: i % 2 == 0 ? .user : .assistant,
                    content: "Message \(i) with some content to make it realistic"
                )
            )
        }

        // Should handle large lists without issues
        #expect(viewModel.entries.count == 200)
        #expect(viewModel.hasMessages)

        // Test clearing performance
        viewModel.clearConversation()
        #expect(viewModel.entries.isEmpty)
    }

    @Test("Tool list filtering performance")
    func testToolListFiltering() {
        let allTools = ToolItem.allTools

        // Should have tools in each category
        let productivityTools = allTools.filter { $0.category == .productivity }
        let creativityTools = allTools.filter { $0.category == .creativity }
        let researchTools = allTools.filter { $0.category == .research }
        let developmentTools = allTools.filter { $0.category == .development }
        let communicationTools = allTools.filter { $0.category == .communication }

        #expect(!productivityTools.isEmpty)
        #expect(!creativityTools.isEmpty)
        #expect(!researchTools.isEmpty)
        #expect(!developmentTools.isEmpty)
        #expect(!communicationTools.isEmpty)

        // Check for premium vs free tools
        let premiumTools = allTools.filter { $0.isPremium }
        let freeTools = allTools.filter { !$0.isPremium }

        #expect(!premiumTools.isEmpty)
        #expect(!freeTools.isEmpty)
        #expect(freeTools.count > premiumTools.count) // Most tools should be free
    }
}