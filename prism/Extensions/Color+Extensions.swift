//
//  Color+Extensions.swift
//  prism
//
//  Created by Andrew Bierman on 10/15/25.
//

import SwiftUI

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

// MARK: - Semantic Color Definitions
extension Color {

    // MARK: - Primary App Colors
    /// Primary brand color that adapts to the platform
    static var prismPrimary: Color {
        #if os(macOS)
        return Color(.systemBlue)
        #elseif os(iOS)
        return Color(.systemBlue)
        #elseif os(visionOS)
        return Color.white
        #else
        return Color.blue
        #endif
    }

    /// Secondary brand color for supporting elements
    static var prismSecondary: Color {
        #if os(macOS)
        return Color(.systemPurple)
        #elseif os(iOS)
        return Color(.systemPurple)
        #elseif os(visionOS)
        return Color.purple.opacity(0.8)
        #else
        return Color.purple
        #endif
    }

    /// Accent color for interactive elements
    static var prismAccent: Color {
        #if os(macOS)
        return Color(.controlAccentColor)
        #elseif os(iOS)
        return Color(.tintColor)
        #elseif os(visionOS)
        return Color.white
        #else
        return Color.accentColor
        #endif
    }

    // MARK: - Background Colors
    /// Primary background color
    static var backgroundPrimary: Color {
        #if os(macOS)
        return Color(.windowBackgroundColor)
        #elseif os(iOS)
        return Color(.systemBackground)
        #elseif os(visionOS)
        return Color.clear
        #else
        return Color(.systemBackground)
        #endif
    }

    /// Secondary background color for grouped content
    static var backgroundSecondary: Color {
        #if os(macOS)
        return Color(.controlBackgroundColor)
        #elseif os(iOS)
        return Color(.secondarySystemBackground)
        #elseif os(visionOS)
        return Color.black.opacity(0.1)
        #else
        return Color(.secondarySystemBackground)
        #endif
    }

    /// Tertiary background color for cards and elevated content
    static var backgroundTertiary: Color {
        #if os(macOS)
        return Color(.tertiaryLabelColor).opacity(0.1)
        #elseif os(iOS)
        return Color(.tertiarySystemBackground)
        #elseif os(visionOS)
        return Color.white.opacity(0.05)
        #else
        return Color(.tertiarySystemBackground)
        #endif
    }

    /// Grouped background color for forms and lists
    static var backgroundGrouped: Color {
        #if os(macOS)
        return Color(.windowBackgroundColor)
        #elseif os(iOS)
        return Color(.systemGroupedBackground)
        #elseif os(visionOS)
        return Color.clear
        #else
        return Color(.systemGroupedBackground)
        #endif
    }

    // MARK: - Text Colors
    /// Primary text color
    static var textPrimary: Color {
        #if os(macOS)
        return Color(.labelColor)
        #elseif os(iOS)
        return Color(.label)
        #elseif os(visionOS)
        return Color.primary
        #else
        return Color.primary
        #endif
    }

    /// Secondary text color for descriptions and captions
    static var textSecondary: Color {
        #if os(macOS)
        return Color(.secondaryLabelColor)
        #elseif os(iOS)
        return Color(.secondaryLabel)
        #elseif os(visionOS)
        return Color.secondary
        #else
        return Color.secondary
        #endif
    }

    /// Tertiary text color for disabled or less important text
    static var textTertiary: Color {
        #if os(macOS)
        return Color(.tertiaryLabelColor)
        #elseif os(iOS)
        return Color(.tertiaryLabel)
        #elseif os(visionOS)
        return Color.secondary.opacity(0.6)
        #else
        return Color(.tertiaryLabel)
        #endif
    }

    /// Placeholder text color
    static var textPlaceholder: Color {
        #if os(macOS)
        return Color(.placeholderTextColor)
        #elseif os(iOS)
        return Color(.placeholderText)
        #elseif os(visionOS)
        return Color.secondary.opacity(0.5)
        #else
        return Color(.placeholderText)
        #endif
    }

    // MARK: - Border and Separator Colors
    /// Standard border color
    static var borderPrimary: Color {
        #if os(macOS)
        return Color(.separatorColor)
        #elseif os(iOS)
        return Color(.separator)
        #elseif os(visionOS)
        return Color.white.opacity(0.2)
        #else
        return Color(.separator)
        #endif
    }

    /// Subtle border color for light separators
    static var borderSecondary: Color {
        #if os(macOS)
        return Color(.separatorColor).opacity(0.5)
        #elseif os(iOS)
        return Color(.opaqueSeparator)
        #elseif os(visionOS)
        return Color.white.opacity(0.1)
        #else
        return Color(.opaqueSeparator)
        #endif
    }

    // MARK: - Interactive Element Colors
    /// Color for interactive elements in normal state
    static var interactive: Color {
        return prismAccent
    }

    /// Color for interactive elements when hovered
    static var interactiveHover: Color {
        #if os(macOS)
        return prismAccent.opacity(0.8)
        #elseif os(iOS)
        return prismAccent.opacity(0.7)
        #elseif os(visionOS)
        return prismAccent.opacity(0.9)
        #else
        return prismAccent.opacity(0.8)
        #endif
    }

    /// Color for interactive elements when pressed
    static var interactivePressed: Color {
        #if os(macOS)
        return prismAccent.opacity(0.6)
        #elseif os(iOS)
        return prismAccent.opacity(0.5)
        #elseif os(visionOS)
        return prismAccent.opacity(0.7)
        #else
        return prismAccent.opacity(0.6)
        #endif
    }

    /// Color for disabled interactive elements
    static var interactiveDisabled: Color {
        #if os(macOS)
        return Color(.disabledControlTextColor)
        #elseif os(iOS)
        return Color(.systemGray3)
        #elseif os(visionOS)
        return Color.gray.opacity(0.3)
        #else
        return Color(.systemGray3)
        #endif
    }

    // MARK: - Status Colors
    /// Success state color
    static var success: Color {
        #if os(macOS)
        return Color(.systemGreen)
        #elseif os(iOS)
        return Color(.systemGreen)
        #elseif os(visionOS)
        return Color.green
        #else
        return Color.green
        #endif
    }

    /// Warning state color
    static var warning: Color {
        #if os(macOS)
        return Color(.systemOrange)
        #elseif os(iOS)
        return Color(.systemOrange)
        #elseif os(visionOS)
        return Color.orange
        #else
        return Color.orange
        #endif
    }

    /// Error state color
    static var error: Color {
        #if os(macOS)
        return Color(.systemRed)
        #elseif os(iOS)
        return Color(.systemRed)
        #elseif os(visionOS)
        return Color.red
        #else
        return Color.red
        #endif
    }

    /// Information state color
    static var info: Color {
        #if os(macOS)
        return Color(.systemBlue)
        #elseif os(iOS)
        return Color(.systemBlue)
        #elseif os(visionOS)
        return Color.blue
        #else
        return Color.blue
        #endif
    }
}

// MARK: - Platform-Specific System Colors
extension Color {

    /// Returns the platform's selection color
    static var selection: Color {
        #if os(macOS)
        return Color(.selectedControlColor)
        #elseif os(iOS)
        return Color(.systemBlue).opacity(0.2)
        #elseif os(visionOS)
        return Color.white.opacity(0.3)
        #else
        return Color.blue.opacity(0.2)
        #endif
    }

    /// Returns the platform's highlight color
    static var highlight: Color {
        #if os(macOS)
        return Color(.alternateSelectedControlColor)
        #elseif os(iOS)
        return Color(.systemGray5)
        #elseif os(visionOS)
        return Color.white.opacity(0.1)
        #else
        return Color(.systemGray5)
        #endif
    }

    /// Returns the platform's control color
    static var control: Color {
        #if os(macOS)
        return Color(.controlColor)
        #elseif os(iOS)
        return Color(.systemGray6)
        #elseif os(visionOS)
        return Color.clear
        #else
        return Color(.systemGray6)
        #endif
    }

    /// Returns the platform's control text color
    static var controlText: Color {
        #if os(macOS)
        return Color(.controlTextColor)
        #elseif os(iOS)
        return Color(.label)
        #elseif os(visionOS)
        return Color.primary
        #else
        return Color.primary
        #endif
    }
}

// MARK: - Dark Mode Aware Colors
extension Color {

    /// Creates a color that adapts to light and dark mode
    static func adaptive(light: Color, dark: Color) -> Color {
        return Color(.init { traits in
            #if os(macOS)
            let appearance = traits.appearance ?? NSApp.effectiveAppearance
            switch appearance.name {
            case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
                return NSColor(dark)
            default:
                return NSColor(light)
            }
            #elseif os(iOS)
            switch traits.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
            #else
            return NSColor(light)
            #endif
        })
    }

    /// Chat bubble color that adapts to appearance
    static var chatBubbleUser: Color {
        adaptive(
            light: Color(.systemBlue),
            dark: Color(.systemBlue).opacity(0.8)
        )
    }

    /// Assistant chat bubble color
    static var chatBubbleAssistant: Color {
        adaptive(
            light: Color(.systemGray5),
            dark: Color(.systemGray6)
        )
    }

    /// Sidebar background color
    static var sidebarBackground: Color {
        #if os(macOS)
        return Color(.sidebarBackgroundColor)
        #elseif os(iOS)
        return adaptive(
            light: Color(.systemGray6),
            dark: Color(.systemGray6)
        )
        #elseif os(visionOS)
        return Color.clear
        #else
        return Color(.systemGray6)
        #endif
    }

    /// Toolbar background color
    static var toolbarBackground: Color {
        #if os(macOS)
        return Color(.windowBackgroundColor)
        #elseif os(iOS)
        return adaptive(
            light: Color(.systemBackground),
            dark: Color(.systemBackground)
        )
        #elseif os(visionOS)
        return Color.clear
        #else
        return Color(.systemBackground)
        #endif
    }
}

// MARK: - Gradient Helpers
extension Color {

    /// Creates a linear gradient with the specified colors
    static func linearGradient(
        colors: [Color],
        startPoint: UnitPoint = .topLeading,
        endPoint: UnitPoint = .bottomTrailing
    ) -> LinearGradient {
        return LinearGradient(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }

    /// Primary brand gradient
    static var primaryGradient: LinearGradient {
        linearGradient(
            colors: [prismPrimary, prismSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Glass effect gradient
    static var glassGradient: LinearGradient {
        #if os(visionOS)
        return linearGradient(
            colors: [
                Color.white.opacity(0.2),
                Color.white.opacity(0.1),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        #else
        return linearGradient(
            colors: [
                Color.white.opacity(0.3),
                Color.white.opacity(0.1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        #endif
    }

    /// Success gradient for positive actions
    static var successGradient: LinearGradient {
        linearGradient(
            colors: [success, success.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Error gradient for negative actions
    static var errorGradient: LinearGradient {
        linearGradient(
            colors: [error, error.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Creates a radial gradient
    static func radialGradient(
        colors: [Color],
        center: UnitPoint = .center,
        startRadius: CGFloat = 0,
        endRadius: CGFloat = 100
    ) -> RadialGradient {
        return RadialGradient(
            colors: colors,
            center: center,
            startRadius: startRadius,
            endRadius: endRadius
        )
    }

    /// Chat bubble gradient for user messages
    static var userMessageGradient: LinearGradient {
        linearGradient(
            colors: [chatBubbleUser, chatBubbleUser.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Background gradient for the main interface
    static var backgroundGradient: LinearGradient {
        #if os(visionOS)
        return linearGradient(
            colors: [Color.clear, Color.black.opacity(0.1)],
            startPoint: .top,
            endPoint: .bottom
        )
        #else
        return adaptive(
            light: linearGradient(
                colors: [backgroundPrimary, backgroundSecondary],
                startPoint: .top,
                endPoint: .bottom
            ),
            dark: linearGradient(
                colors: [backgroundPrimary, backgroundPrimary.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        #endif
    }
}

// MARK: - Utility Extensions
extension Color {

    /// Returns the color with modified opacity
    func opacity(_ opacity: Double) -> Color {
        return self.opacity(opacity)
    }

    /// Returns a lighter version of the color
    func lighter(by amount: Double = 0.2) -> Color {
        #if os(macOS)
        return Color(NSColor(self).blended(withFraction: amount, of: .white) ?? NSColor(self))
        #elseif os(iOS)
        return Color(UIColor(self).lighter(by: amount))
        #else
        return self
        #endif
    }

    /// Returns a darker version of the color
    func darker(by amount: Double = 0.2) -> Color {
        #if os(macOS)
        return Color(NSColor(self).blended(withFraction: amount, of: .black) ?? NSColor(self))
        #elseif os(iOS)
        return Color(UIColor(self).darker(by: amount))
        #else
        return self
        #endif
    }

    /// Creates a color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Returns the hex string representation of the color
    var hexString: String {
        #if os(macOS)
        let nsColor = NSColor(self)
        guard let components = nsColor.cgColor.components else { return "#000000" }
        #elseif os(iOS)
        let uiColor = UIColor(self)
        guard let components = uiColor.cgColor.components else { return "#000000" }
        #else
        return "#000000"
        #endif

        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)

        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

// MARK: - UIColor Extensions for iOS
#if os(iOS)
extension UIColor {
    func lighter(by amount: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        guard getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return self
        }

        return UIColor(
            hue: hue,
            saturation: max(saturation - amount, 0.0),
            brightness: min(brightness + amount, 1.0),
            alpha: alpha
        )
    }

    func darker(by amount: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        guard getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return self
        }

        return UIColor(
            hue: hue,
            saturation: min(saturation + amount, 1.0),
            brightness: max(brightness - amount, 0.0),
            alpha: alpha
        )
    }
}
#endif