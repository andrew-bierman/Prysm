//
//  NavigationCoordinator.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import SwiftUI
import Observation

@Observable
final class NavigationCoordinator {
    @MainActor static let shared = NavigationCoordinator()

    var tabSelection: TabSelection = .chat
    var splitViewSelection: TabSelection? = .chat

    private init() {}

    @MainActor
    public func navigate(to tab: TabSelection) {
        tabSelection = tab
        splitViewSelection = tab
    }
}