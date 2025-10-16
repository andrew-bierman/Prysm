//
//  Color+Extensions.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import SwiftUI

extension Color {
    /// The main accent color used throughout the app - using a prism-like purple/indigo
    static var main: Color {
        Color.indigo
    }

    /// Secondary background color that adapts to the platform
    static var secondaryBackgroundColor: Color {
        #if os(iOS)
        Color(UIColor.secondarySystemBackground)
        #elseif os(macOS)
        Color(NSColor.controlBackgroundColor)
        #else
        Color.gray.opacity(0.1)
        #endif
    }

    /// Tertiary background color
    static var tertiaryBackgroundColor: Color {
        #if os(iOS)
        Color(UIColor.tertiarySystemBackground)
        #elseif os(macOS)
        Color(NSColor.windowBackgroundColor)
        #else
        Color.gray.opacity(0.05)
        #endif
    }
}