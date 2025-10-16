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
            Tab(TabSelection.chat.displayName, systemImage: TabSelection.chat.systemImage, value: .chat) {
                NavigationStack {
                    ChatView(viewModel: $chatViewModel)
                }
            }

            Tab(TabSelection.assistant.displayName, systemImage: TabSelection.assistant.systemImage, value: .assistant) {
                NavigationStack {
                    AssistantView()
                }
            }

            Tab(TabSelection.model.displayName, systemImage: TabSelection.model.systemImage, value: .model) {
                NavigationStack {
                    ModelView()
                }
            }

            Tab(TabSelection.settings.displayName, systemImage: TabSelection.settings.systemImage, value: .settings) {
                NavigationStack {
                    SettingsView()
                }
            }
        }
#if os(iOS)
        .tabBarMinimizeBehavior(.onScrollDown)
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