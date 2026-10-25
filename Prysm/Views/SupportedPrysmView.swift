import SwiftUI
import FoundationModels

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
struct SupportedPrysmView: View {
    @State private var isModelAvailable = true
    @State private var unavailabilityReason: SystemLanguageModel.Availability.UnavailableReason?
    @State private var showModelUnavailableWarning = false
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @State private var showWelcome = false

    var body: some View {
        AdaptiveNavigationView()
#if os(macOS)
            .frame(minWidth: 900, minHeight: 600)
#endif
            .onAppear {
                checkModelAvailability()
                if !hasSeenWelcome { showWelcome = true }
            }
            .sheet(isPresented: $showModelUnavailableWarning) {
                ModelUnavailableView(reason: unavailabilityReason)
            }
            .sheet(isPresented: $showWelcome) {
                WelcomeView(isPresented: $showWelcome)
            }
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
