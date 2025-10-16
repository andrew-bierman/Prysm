//
//  AdaptiveNavigationView.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import SwiftUI
import FoundationModels

struct AdaptiveNavigationView: View {
    @State private var chatViewModel = ChatViewModel()
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private let navigationCoordinator = NavigationCoordinator.shared

    var body: some View {
#if os(iOS)
        if horizontalSizeClass == .compact {
            // iPhone or iPad in compact width
            tabBasedNavigation
        } else {
            // iPad in regular width
            splitViewNavigation
        }
#else
        // macOS always uses split view
        splitViewNavigation
#endif
    }

    private var tabBasedNavigation: some View {
        TabView(selection: .init(
            get: { navigationCoordinator.tabSelection },
            set: { navigationCoordinator.tabSelection = $0 }
        )) {
            NavigationStack {
                ChatView(viewModel: $chatViewModel)
            }
            .tabItem {
                Label(TabSelection.chat.displayName, systemImage: TabSelection.chat.systemImage)
            }
            .tag(TabSelection.chat)

            NavigationStack {
                AssistantView()
            }
            .tabItem {
                Label(TabSelection.assistant.displayName, systemImage: TabSelection.assistant.systemImage)
            }
            .tag(TabSelection.assistant)

            NavigationStack {
                ModelView()
            }
            .tabItem {
                Label(TabSelection.model.displayName, systemImage: TabSelection.model.systemImage)
            }
            .tag(TabSelection.model)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(TabSelection.settings.displayName, systemImage: TabSelection.settings.systemImage)
            }
            .tag(TabSelection.settings)
        }
#if os(iOS)
        .ignoresSafeArea(.keyboard)
#endif
        .onChange(of: navigationCoordinator.tabSelection) { _, newValue in
            navigationCoordinator.splitViewSelection = newValue
        }
    }

    private var splitViewNavigation: some View {
        NavigationSplitView(
            columnVisibility: $columnVisibility
        ) {
            SidebarView(selection: .init(
                get: { navigationCoordinator.splitViewSelection },
                set: { navigationCoordinator.splitViewSelection = $0 }
            ))
        } detail: {
            detailView
        }
        .navigationSplitViewStyle(.balanced)
        .onChange(of: navigationCoordinator.splitViewSelection) { _, newValue in
            if let newValue {
                navigationCoordinator.tabSelection = newValue
            }
        }
    }

    @ViewBuilder
    private var detailView: some View {
        switch navigationCoordinator.splitViewSelection ?? .chat {
        case .chat:
            NavigationStack {
                ChatView(viewModel: $chatViewModel)
            }
        case .assistant:
            NavigationStack {
                AssistantView()
            }
        case .model:
            NavigationStack {
                ModelView()
            }
        case .settings:
            NavigationStack {
                SettingsView()
            }
        }
    }
}

#Preview {
    AdaptiveNavigationView()
}