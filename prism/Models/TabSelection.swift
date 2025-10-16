//
//  TabSelection.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import Foundation

enum TabSelection: String, CaseIterable, Hashable {
    case chat
    case examples
    case tools
    case languages
    case settings

    var displayName: String {
        switch self {
        case .chat:
            return "Chat"
        case .examples:
            return "Examples"
        case .tools:
            return "Tools"
        case .languages:
            return "Languages"
        case .settings:
            return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .chat:
            return "bubble.left.and.bubble.right"
        case .examples:
            return "sparkles"
        case .tools:
            return "wrench.and.screwdriver"
        case .languages:
            return "globe"
        case .settings:
            return "gear"
        }
    }
}