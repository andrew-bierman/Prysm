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

@MainActor
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
        let examples: [ExampleType] = [.recipes, .bookRecommendations, .travelPlanning, .productReviews]

        for example in examples {
            #expect(!example.title.isEmpty)
            #expect(!example.subtitle.isEmpty)
            #expect(!example.icon.isEmpty)
            let _ = example.accentColor // Should not crash
        }
    }

    @Test("Tool item model properties")
    func testToolItemModel() {
        let tool = ToolItem(
            id: "testTool",
            name: "Test Tool",
            description: "A tool for testing",
            icon: "wrench",
            category: .development,
            isPro: false
        )

        #expect(tool.id == "testTool")
        #expect(tool.name == "Test Tool")
        #expect(tool.description == "A tool for testing")
        #expect(tool.icon == "wrench")
        #expect(tool.category == .development)
        #expect(tool.isPro == false)

        // Test pro tool
        let proTool = ToolItem(
            id: "proTool",
            name: "Pro Tool",
            description: "A pro tool",
            icon: "star",
            category: .creativity,
            isPro: true
        )
        #expect(proTool.isPro == true)
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
            isPro: false
        )

        #expect(model.id == "testModel")
        #expect(model.name == "Test Model")
        #expect(model.description == "A test language model")
        #expect(model.capabilities.count == 3)
        #expect(model.capabilities.contains("Cap1"))
        #expect(model.icon == "brain")
        #expect(model.accentColor == .blue)
        #expect(model.isPro == false)
    }
}

// MARK: - View Helper Tests

extension UIComponentTests {

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
        let _ = ExampleType.travelPlanning.accentColor
        let _ = ExampleType.productReviews.accentColor
    }
}

// MARK: - Tool List Tests

extension UIComponentTests {

    @Test("Tool list filtering")
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

        // Check for pro vs free tools
        let proTools = allTools.filter { $0.isPro }
        let freeTools = allTools.filter { !$0.isPro }

        #expect(!proTools.isEmpty)
        #expect(!freeTools.isEmpty)
        #expect(freeTools.count > proTools.count) // Most tools should be free
    }
}
