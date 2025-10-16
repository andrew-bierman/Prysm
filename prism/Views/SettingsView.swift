//
//  SettingsView.swift
//  Prism
//
//  Placeholder for Settings
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.largeTitle)
                    .bold()

                Text("Coming soon: App settings and preferences")
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}