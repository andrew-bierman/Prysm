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
    static let appName = "Prysm AI"

    /// Short name for compact displays
    static let appShortName = "Prysm"

    /// The app's tagline
    static let tagline = "Your AI companion powered by Apple Intelligence"

    /// Bundle identifier base (without platform suffix)
    static let bundleIdBase = "andrewbierman.prysm"

    /// Company/Developer name
    static let developerName = "Andrew Bierman"

    // MARK: - AI Assistant Identity

    /// How the AI introduces itself
    static let assistantName = "Prysm AI"

    /// Base instructions for the AI
    static let assistantInstructions = """
        You are \(assistantName), an AI assistant powered by Apple's Foundation Models framework.
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

    /// App subtitle (30 characters max)
    static let appSubtitle = "Powered by Apple Intelligence"

    /// Promotional text (170 characters max) - can be updated anytime
    static let promotionalText = "Experience the future of AI assistance with Prysm AI - built on Apple's Foundation Models for uncompromising privacy and performance."

    /// App Store keywords (100 characters total)
    static let keywords = [
        "AI", "assistant", "chat", "Apple Intelligence",
        "Foundation Models", "on-device", "privacy",
        "GPT", "language model", "productivity"
    ]

    /// App Store description
    static let appDescription = """
    Prysm AI brings the power of advanced language models directly to your Apple devices, with a focus on privacy, performance, and ease of use.

    KEY FEATURES:

    ● Private & Secure
    All processing happens on-device using Apple's Foundation Models framework. Your conversations never leave your device, ensuring complete privacy.

    ● Smart Conversations
    Engage in natural, contextual conversations with an AI that understands nuance and can help with a wide variety of tasks.

    ● Creative Tools
    Generate structured content including recipes, travel itineraries, book summaries, and product reviews with specialized templates.

    ● Adaptive Interface
    Beautiful, native experience optimized for iPhone, iPad, and Mac with support for light/dark modes and customizable themes.

    ● No Subscription Required
    Core features are completely free with no ads or tracking. Optional premium features enhance your experience.

    ● Examples Library
    Get inspired with curated prompts and templates across categories like productivity, creativity, learning, and entertainment.

    PERFECT FOR:
    • Students and educators
    • Writers and content creators
    • Developers and designers
    • Business professionals
    • Anyone curious about AI

    Prysm AI respects your privacy while delivering powerful AI capabilities. No account required, no data collection, just pure AI assistance when you need it.

    Built with SwiftUI and powered by Apple Intelligence, Prysm AI represents the future of on-device AI assistance.
    """

    /// What's New text for updates
    static let whatsNew = """
    Version 1.0 - Initial Release
    • Beautiful native interface for iOS, iPadOS, and macOS
    • Smart conversation management with context awareness
    • Creative content generation tools
    • Complete privacy with on-device processing
    • Customizable themes and settings
    • Example prompts library
    • No subscription required
    """

    /// App category
    static let appCategory = "Productivity"

    /// Secondary category
    static let secondaryCategory = "Utilities"

    /// Content rating
    static let contentRating = "4+"

    /// Copyright text
    static let copyright = "© 2024 \(developerName). All rights reserved."

    // MARK: - App Store Screenshots

    /// Screenshot captions for App Store (5 screenshots recommended)
    static let screenshotCaptions = [
        "Natural AI Conversations",
        "Creative Content Tools",
        "Complete Privacy",
        "Beautiful Dark Mode",
        "Cross-Platform Sync"
    ]

    /// App preview video script (30 seconds max)
    static let appPreviewScript = """
    Opening: "Meet Prysm AI - Your private AI assistant"
    0-5s: Show app launch and welcome screen
    5-10s: Demo conversation with AI
    10-15s: Show content generation tools
    15-20s: Highlight privacy features
    20-25s: Show customization options
    25-30s: End card with "Download Prysm AI Today"
    """

    // MARK: - Review Prompts

    /// When to show review prompt (after X uses)
    static let reviewPromptThreshold = 10

    /// Review prompt message
    static let reviewPromptMessage = "Enjoying Prysm AI? Would you mind taking a moment to rate us?"

    // MARK: - Search Ads

    /// Search ads metadata
    static let searchAdsKeywords = [
        "AI chat app",
        "GPT app",
        "AI assistant iOS",
        "private AI",
        "on-device AI",
        "Apple Intelligence app"
    ]

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