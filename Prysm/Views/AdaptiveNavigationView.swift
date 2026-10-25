//
//  AdaptiveNavigationView.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import SwiftUI
import FoundationModels

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
struct AdaptiveNavigationView: View {
    @State private var chatViewModel = ChatViewModel()
    @State private var messageText = ""
    @State private var assistantSelectedTab = 0
    @State private var modelSelectedTab = 0
    @State private var showingInstructionsSheet = false
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private let navigationCoordinator = NavigationCoordinator.shared

    var body: some View {
        Group {
#if os(iOS)
            if horizontalSizeClass == .regular {
                splitViewNavigation
            } else {
                tabBasedNavigation
            }
#else
            splitViewNavigation
#endif
        }
        // Presentation and draft lifetime must not follow the compact/regular branch.
        .sheet(isPresented: $showingInstructionsSheet) {
            InstructionsSheet(isPresented: $showingInstructionsSheet)
        }
    }

    private var tabBasedNavigation: some View {
        TabView(selection: .init(
            get: { navigationCoordinator.tabSelection },
            set: { navigationCoordinator.tabSelection = $0 }
        )) {
            NavigationStack {
                ChatView(viewModel: $chatViewModel, messageText: $messageText)
            }
            .tabItem {
                Label(TabSelection.chat.displayName, systemImage: TabSelection.chat.systemImage)
            }
            .tag(TabSelection.chat)

            NavigationStack {
                AssistantView(selectedTab: $assistantSelectedTab) {
                    showingInstructionsSheet = true
                }
            }
            .tabItem {
                Label(TabSelection.assistant.displayName, systemImage: TabSelection.assistant.systemImage)
            }
            .tag(TabSelection.assistant)

            NavigationStack {
                ModelView(selectedTab: $modelSelectedTab)
            }
            .tabItem {
                Label(TabSelection.model.displayName, systemImage: TabSelection.model.systemImage)
            }
            .tag(TabSelection.model)

            NavigationStack {
                SettingsView()
            }
            .environment(chatViewModel)
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
                ChatView(viewModel: $chatViewModel, messageText: $messageText)
            }
        case .assistant:
            NavigationStack {
                AssistantView(selectedTab: $assistantSelectedTab) {
                    showingInstructionsSheet = true
                }
            }
        case .model:
            NavigationStack {
                ModelView(selectedTab: $modelSelectedTab)
            }
        case .settings:
            NavigationStack {
                SettingsView()
            }
            .environment(chatViewModel)
        }
    }
}

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
#Preview {
    AdaptiveNavigationView()
}