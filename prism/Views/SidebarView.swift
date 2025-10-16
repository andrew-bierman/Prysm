//
//  SidebarView.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import SwiftUI

struct SidebarView: View {
    @Binding var selection: TabSelection?

    var body: some View {
        List(selection: $selection) {
            Section {
                NavigationLink(value: TabSelection.chat) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(TabSelection.chat.displayName)
                                .font(.body)
                            Text(TabSelection.chat.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: TabSelection.chat.systemImage)
                            .symbolRenderingMode(.multicolor)
                    }
                }
            }

            Section("Configuration") {
                ForEach([TabSelection.assistant, TabSelection.model], id: \.self) { tab in
                    NavigationLink(value: tab) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(tab.displayName)
                                    .font(.body)
                                Text(tab.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: tab.systemImage)
                                .symbolRenderingMode(.multicolor)
                        }
                    }
                }
            }

            Section {
                NavigationLink(value: TabSelection.settings) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(TabSelection.settings.displayName)
                                .font(.body)
                            Text(TabSelection.settings.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: TabSelection.settings.systemImage)
                            .symbolRenderingMode(.multicolor)
                    }
                }
            }
        }
        .navigationTitle(AppConfig.appName)
#if os(macOS)
        .navigationSplitViewColumnWidth(min: 250, ideal: 280, max: 350)
#endif
        .listStyle(.sidebar)
    }
}

#Preview {
    SidebarView(selection: .constant(.chat))
}