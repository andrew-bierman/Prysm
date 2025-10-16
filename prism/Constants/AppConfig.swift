//
//  AppConfig.swift
//  Prism
//
//  Centralized app configuration and branding
//

import Foundation
import SwiftUI

/// Central configuration for app branding and metadata
enum AppConfig {

    // MARK: - Branding

    /// The display name of the app
    static let appName = "Luma AI"

    /// Short name for compact displays
    static let appShortName = "Luma"

    /// The app's tagline
    static let tagline = "Your AI companion powered by Apple Intelligence"

    /// Bundle identifier base (without platform suffix)
    static let bundleIdBase = "andrewbierman.luma-ai"

    /// Company/Developer name
    static let developerName = "Andrew Bierman"

    // MARK: - AI Assistant Identity

    /// How the AI introduces itself
    static let assistantName = "Luma AI"

    /// Base instructions for the AI
    static let assistantInstructions = """
        You are \(assistantName), a helpful AI assistant powered by Apple's Foundation Models framework.
        You aim to be helpful, harmless, and honest in all your interactions.
        Provide clear, concise, and accurate responses.
        """

    /// Welcome message for new users
    static let welcomeTitle = "Welcome to \(appName)"

    /// Welcome subtitle
    static let welcomeSubtitle = tagline

    // MARK: - Feature Flags

    /// Whether to show premium features
    static let showPremiumFeatures = true

    /// Whether to enable developer mode options
    static let enableDeveloperMode = false

    // MARK: - App Store Metadata

    /// App Store keywords
    static let keywords = [
        "AI", "assistant", "chat", "Apple Intelligence",
        "Foundation Models", "on-device", "privacy",
        "GPT", "language model", "productivity"
    ]

    /// App category
    static let appCategory = "Productivity"

    /// Content rating
    static let contentRating = "4+"

    // MARK: - URLs

    /// Support URL
    static let supportURL = URL(string: "https://github.com/\(developerName.lowercased().replacingOccurrences(of: " ", with: ""))/\(appShortName.lowercased())")

    /// Privacy policy URL
    static let privacyURL = URL(string: "https://example.com/privacy")

    /// Terms of service URL
    static let termsURL = URL(string: "https://example.com/terms")

    // MARK: - Version Info

    /// Current app version
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    /// Build number
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    /// Full version string
    static var fullVersionString: String {
        "Version \(appVersion) (\(buildNumber))"
    }

    // MARK: - Theme Colors

    /// Primary brand color
    static let primaryColor = Color.purple

    /// Secondary brand color
    static let secondaryColor = Color.blue

    /// Accent color for UI elements
    static let accentColor = Color.accentColor

    // MARK: - Limits

    /// Maximum message length
    static let maxMessageLength = 4000

    /// Maximum conversation history
    static let maxConversationHistory = 100

    /// Default token limit
    static let defaultMaxTokens = 2048
}

// MARK: - Helper Extensions

extension AppConfig {

    /// Get the appropriate app name based on available width
    static func appName(for width: CGFloat) -> String {
        width < 150 ? appShortName : appName
    }

    /// Format the app name with optional trademark
    static func formattedAppName(includeTM: Bool = false) -> String {
        includeTM ? "\(appName)™" : appName
    }

    /// Get platform-specific bundle ID
    static var platformBundleId: String {
        #if os(iOS)
        return "\(bundleIdBase).ios"
        #elseif os(macOS)
        return "\(bundleIdBase).macos"
        #else
        return bundleIdBase
        #endif
    }
}