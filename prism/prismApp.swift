//
//  PrismApp.swift
//  Prism
//
//  Created by Andrew Bierman on 10/15/25.
//

import SwiftUI
import SwiftData
import FoundationModels

@main
struct PrismApp: App {
    @State private var isModelAvailable = true
    @State private var unavailabilityReason: SystemLanguageModel.Availability.UnavailableReason?
    @State private var showModelUnavailableWarning = false
    @State private var chatViewModel = ChatViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ChatView(viewModel: $chatViewModel)
            }
#if os(macOS)
            .frame(minWidth: 800, minHeight: 600)
#endif
            .onAppear {
                checkModelAvailability()
            }
            .sheet(isPresented: $showModelUnavailableWarning) {
                ModelUnavailableView(reason: unavailabilityReason)
            }
        }
#if os(macOS)
        .defaultSize(width: 1000, height: 700)
#endif
    }

    private func checkModelAvailability() {
        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            isModelAvailable = true
            showModelUnavailableWarning = false
        case .unavailable(let reason):
            isModelAvailable = false
            unavailabilityReason = reason
            showModelUnavailableWarning = true
        }
    }
}