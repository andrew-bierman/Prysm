import SwiftUI

/// Does not initialize Foundation Models or modify the user's saved preferences.
struct OperatingSystemUnavailableView: View {
    var body: some View {
        ContentUnavailableView {
            Label("System update required", systemImage: "arrow.up.circle")
        } description: {
            Text("Prysm’s on-device AI requires iOS 26, macOS 26, or visionOS 26 or later, on a device that supports Apple Intelligence. Update your system to use Prysm’s AI features.")
        }
    }
}
