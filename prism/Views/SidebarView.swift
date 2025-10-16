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
            ForEach(TabSelection.allCases, id: \.self) { tab in
                NavigationLink(value: tab) {
                    Label(tab.displayName, systemImage: tab.systemImage)
                }
            }
        }
        .navigationTitle("Prism")
#if os(macOS)
        .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
#endif
    }
}

#Preview {
    SidebarView(selection: .constant(.chat))
}