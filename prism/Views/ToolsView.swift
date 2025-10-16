//
//  ToolsView.swift
//  Prism
//
//  Placeholder for Tools feature
//

import SwiftUI

struct ToolsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Tools & Integrations")
                    .font(.largeTitle)
                    .bold()

                Text("Coming soon: Custom tools and integrations")
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Tools")
    }
}

#Preview {
    NavigationStack {
        ToolsView()
    }
}