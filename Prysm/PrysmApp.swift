import SwiftUI

@main
struct PrysmApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
#if DEBUG
                if ProcessInfo.processInfo.arguments.contains("--ui-test-generation-cancellation") {
                    GenerationCancellationTestView()
                } else {
                    SupportedPrysmView()
                }
#else
                SupportedPrysmView()
#endif
            } else {
                OperatingSystemUnavailableView()
            }
        }
#if os(macOS)
        .defaultSize(width: 1200, height: 800)
#endif
    }
}
