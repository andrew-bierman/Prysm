//
//  ModelView.swift
//  Prism
//
//  Model selection and generation options
//

import SwiftUI

struct ModelView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Segmented picker for sub-sections
            Picker("Model Configuration", selection: $selectedTab) {
                Text("Models").tag(0)
                Text("Parameters").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            // Content based on selection
            switch selectedTab {
            case 0:
                LanguagesView()
            case 1:
                GenerationOptionsView()
            default:
                LanguagesView()
            }
        }
        .navigationTitle("Model")
#if os(iOS)
        .navigationBarTitleDisplayMode(.large)
#endif
    }
}

#Preview {
    NavigationStack {
        ModelView()
    }
}