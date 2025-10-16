//
//  TabSelection.swift
//  Prism
//
//  Navigation structure for the app
//

import Foundation

enum TabSelection: String, CaseIterable, Hashable {
    case chat
    case assistant
    case model
    case settings

    var displayName: String {
        switch self {
        case .chat:
            return "Chat"
        case .assistant:
            return "Assistant"
        case .model:
            return "Model"
        case .settings:
            return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .chat:
            return "message.fill"
        case .assistant:
            return "wand.and.stars"
        case .model:
            return "brain"
        case .settings:
            return "gearshape.fill"
        }
    }

    var description: String {
        switch self {
        case .chat:
            return "Start a conversation"
        case .assistant:
            return "Configure AI behavior"
        case .model:
            return "Choose language model"
        case .settings:
            return "App preferences"
        }
    }
}