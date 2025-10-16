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

    var body: some Scene {
        WindowGroup {
            AdaptiveNavigationView()
#if os(macOS)
            .frame(minWidth: 900, minHeight: 600)
#endif
            .onAppear {
                checkModelAvailability()
            }
            .sheet(isPresented: $showModelUnavailableWarning) {
                ModelUnavailableView(reason: unavailabilityReason)
            }
        }
#if os(macOS)
        .defaultSize(width: 1200, height: 800)
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