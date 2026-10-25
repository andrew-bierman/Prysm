//
//  ModelView.swift
//  Prism
//
//  Model selection and generation options
//

import SwiftUI

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
struct ModelView: View {
    @Binding var selectedTab: Int

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

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
#Preview {
    @Previewable @State var selectedTab = 0
    NavigationStack {
        ModelView(selectedTab: $selectedTab)
    }
}