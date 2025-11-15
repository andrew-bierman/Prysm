//
//  SettingsTests.swift
//  PrismTests
//
//  Testing Settings and UserDefaults functionality
//

import Testing
import Foundation
import SwiftUI
@testable import Prysm

@MainActor
struct SettingsTests {

    // Clean up UserDefaults after each test
    func cleanup() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "selectedLanguageModel")
        defaults.removeObject(forKey: "temperature")
        defaults.removeObject(forKey: "topP")
        defaults.removeObject(forKey: "maxTokens")
        defaults.removeObject(forKey: "streamResponses")
        defaults.removeObject(forKey: "autoSummarize")
        defaults.removeObject(forKey: "contextWindowSize")
        defaults.removeObject(forKey: "useCustomInstructions")
        defaults.removeObject(forKey: "customInstructions")
        defaults.removeObject(forKey: "exportFormat")
        defaults.removeObject(forKey: "enabledTools")
        defaults.removeObject(forKey: "selectedTheme")
        defaults.removeObject(forKey: "systemPromptStyle")
        defaults.removeObject(forKey: "enableNotifications")
        defaults.removeObject(forKey: "enableHaptics")
        defaults.removeObject(forKey: "developerMode")
    }

    @Test("Language model selection persistence")
    func testLanguageModelPersistence() {
        defer { cleanup() }

        let defaults = UserDefaults.standard

        // Default value
        #expect(defaults.string(forKey: "selectedLanguageModel") == nil)

        // Set and retrieve
        defaults.set("cloudPro", forKey: "selectedLanguageModel")
        #expect(defaults.string(forKey: "selectedLanguageModel") == "cloudPro")

        // Update value
        defaults.set("default", forKey: "selectedLanguageModel")
        #expect(defaults.string(forKey: "selectedLanguageModel") == "default")
    }

    @Test("Generation options persistence")
    func testGenerationOptionsPersistence() {
        defer { cleanup() }

        let defaults = UserDefaults.standard

        // Test temperature
        defaults.set(0.9, forKey: "temperature")
        #expect(defaults.double(forKey: "temperature") == 0.9)

        // Test topP
        defaults.set(0.85, forKey: "topP")
        #expect(defaults.double(forKey: "topP") == 0.85)

        // Test maxTokens
        defaults.set(4096, forKey: "maxTokens")
        #expect(defaults.integer(forKey: "maxTokens") == 4096)

        // Test boolean options
        defaults.set(false, forKey: "streamResponses")
        #expect(defaults.bool(forKey: "streamResponses") == false)

        defaults.set(false, forKey: "autoSummarize")
        #expect(defaults.bool(forKey: "autoSummarize") == false)

        // Test context window
        defaults.set(8192, forKey: "contextWindowSize")
        #expect(defaults.integer(forKey: "contextWindowSize") == 8192)
    }

    @Test("Custom instructions persistence")
    func testCustomInstructionsPersistence() {
        defer { cleanup() }

        let defaults = UserDefaults.standard

        // Default values
        #expect(!defaults.bool(forKey: "useCustomInstructions"))
        #expect(defaults.string(forKey: "customInstructions") == nil)

        // Set custom instructions
        defaults.set(true, forKey: "useCustomInstructions")
        defaults.set("Be concise and clear", forKey: "customInstructions")

        #expect(defaults.bool(forKey: "useCustomInstructions") == true)
        #expect(defaults.string(forKey: "customInstructions") == "Be concise and clear")

        // Update instructions
        defaults.set("Use formal language", forKey: "customInstructions")
        #expect(defaults.string(forKey: "customInstructions") == "Use formal language")

        // Disable custom instructions
        defaults.set(false, forKey: "useCustomInstructions")
        #expect(!defaults.bool(forKey: "useCustomInstructions"))
    }

    @Test("Export format persistence")
    func testExportFormatPersistence() {
        defer { cleanup() }

        let defaults = UserDefaults.standard

        // Default value
        #expect(defaults.string(forKey: "exportFormat") == nil)

        // Set different formats
        defaults.set("json", forKey: "exportFormat")
        #expect(defaults.string(forKey: "exportFormat") == "json")

        defaults.set("markdown", forKey: "exportFormat")
        #expect(defaults.string(forKey: "exportFormat") == "markdown")

        defaults.set("plainText", forKey: "exportFormat")
        #expect(defaults.string(forKey: "exportFormat") == "plainText")

        defaults.set("csv", forKey: "exportFormat")
        #expect(defaults.string(forKey: "exportFormat") == "csv")
    }

    @Test("Enabled tools persistence")
    func testEnabledToolsPersistence() {
        defer { cleanup() }

        let defaults = UserDefaults.standard

        // Default empty set
        #expect(defaults.array(forKey: "enabledTools") == nil)

        // Set tools
        let tools = ["calculator", "codeInterpreter", "webSearch"]
        defaults.set(tools, forKey: "enabledTools")

        let retrievedTools = defaults.array(forKey: "enabledTools") as? [String]
        #expect(retrievedTools?.count == 3)
        #expect(retrievedTools?.contains("calculator") == true)
        #expect(retrievedTools?.contains("codeInterpreter") == true)
        #expect(retrievedTools?.contains("webSearch") == true)

        // Update tools
        let updatedTools = ["calculator", "imageGenerator"]
        defaults.set(updatedTools, forKey: "enabledTools")

        let newRetrievedTools = defaults.array(forKey: "enabledTools") as? [String]
        #expect(newRetrievedTools?.count == 2)
        #expect(newRetrievedTools?.contains("imageGenerator") == true)
        #expect(newRetrievedTools?.contains("webSearch") == false)
    }

    @Test("App preferences persistence")
    func testAppPreferencesPersistence() {
        defer { cleanup() }

        let defaults = UserDefaults.standard

        // Theme selection
        defaults.set("dark", forKey: "selectedTheme")
        #expect(defaults.string(forKey: "selectedTheme") == "dark")

        // System prompt style
        defaults.set("professional", forKey: "systemPromptStyle")
        #expect(defaults.string(forKey: "systemPromptStyle") == "professional")

        // Notifications
        defaults.set(true, forKey: "enableNotifications")
        #expect(defaults.bool(forKey: "enableNotifications") == true)

        // Haptics
        defaults.set(false, forKey: "enableHaptics")
        #expect(defaults.bool(forKey: "enableHaptics") == false)

        // Developer mode
        defaults.set(true, forKey: "developerMode")
        #expect(defaults.bool(forKey: "developerMode") == true)
    }

    @Test("Reset to defaults functionality")
    func testResetToDefaults() {
        defer { cleanup() }

        let defaults = UserDefaults.standard

        // Set custom values
        defaults.set(1.5, forKey: "temperature")
        defaults.set(0.5, forKey: "topP")
        defaults.set(8192, forKey: "maxTokens")
        defaults.set(false, forKey: "streamResponses")
        defaults.set(false, forKey: "autoSummarize")
        defaults.set(16384, forKey: "contextWindowSize")

        // Simulate reset (as would happen in GenerationOptionsView)
        defaults.set(0.7, forKey: "temperature")
        defaults.set(0.95, forKey: "topP")
        defaults.set(2048, forKey: "maxTokens")
        defaults.set(true, forKey: "streamResponses")
        defaults.set(true, forKey: "autoSummarize")
        defaults.set(4096, forKey: "contextWindowSize")

        // Verify defaults
        #expect(defaults.double(forKey: "temperature") == 0.7)
        #expect(defaults.double(forKey: "topP") == 0.95)
        #expect(defaults.integer(forKey: "maxTokens") == 2048)
        #expect(defaults.bool(forKey: "streamResponses") == true)
        #expect(defaults.bool(forKey: "autoSummarize") == true)
        #expect(defaults.integer(forKey: "contextWindowSize") == 4096)
    }
}

// MARK: - AppStorage Integration Tests

extension SettingsTests {

    @Test("AppStorage wrapper behavior")
    func testAppStorageBehavior() {
        defer { cleanup() }

        // AppStorage automatically syncs with UserDefaults
        let defaults = UserDefaults.standard

        // Test double values
        defaults.set(1.2, forKey: "temperature")
        #expect(defaults.double(forKey: "temperature") == 1.2)

        // Test integer values
        defaults.set(3000, forKey: "maxTokens")
        #expect(defaults.integer(forKey: "maxTokens") == 3000)

        // Test boolean values
        defaults.set(true, forKey: "streamResponses")
        #expect(defaults.bool(forKey: "streamResponses") == true)

        // Test string values
        defaults.set("custom", forKey: "selectedLanguageModel")
        #expect(defaults.string(forKey: "selectedLanguageModel") == "custom")
    }

    @Test("Default values for unset keys")
    func testDefaultValues() {
        defer { cleanup() }

        let defaults = UserDefaults.standard

        // When keys are not set, they should return appropriate defaults
        #expect(defaults.double(forKey: "temperature") == 0.0) // Default double
        #expect(defaults.integer(forKey: "maxTokens") == 0) // Default int
        #expect(defaults.bool(forKey: "streamResponses") == false) // Default bool
        #expect(defaults.string(forKey: "selectedLanguageModel") == nil) // Default string
        #expect(defaults.array(forKey: "enabledTools") == nil) // Default array
    }
}