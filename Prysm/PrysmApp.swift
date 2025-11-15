//
//  PrysmApp.swift
//  Prysm
//
//  Created by Andrew Bierman on 10/15/25.
//

import SwiftUI
import FoundationModels

@main
struct PrysmApp: App {
    @State private var isModelAvailable = true
    @State private var unavailabilityReason: SystemLanguageModel.Availability.UnavailableReason?
    @State private var showModelUnavailableWarning = false
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @State private var showWelcome = false

    var body: some Scene {
        WindowGroup {
            AdaptiveNavigationView()
#if os(macOS)
            .frame(minWidth: 900, minHeight: 600)
#endif
            .onAppear {
                checkModelAvailability()
                if !hasSeenWelcome {
                    showWelcome = true
                }
            }
            .sheet(isPresented: $showModelUnavailableWarning) {
                ModelUnavailableView(reason: unavailabilityReason)
            }
            .sheet(isPresented: $showWelcome) {
                WelcomeView(isPresented: $showWelcome)
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