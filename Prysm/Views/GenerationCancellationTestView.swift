#if DEBUG
import SwiftUI

/// Opt-in UI-test host: no system-model query, session, network, or persisted settings.
@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
struct GenerationCancellationTestView: View {
    @State private var viewModel = ContentViewModel(modelAvailability: { .available })
    @State private var showingExample = false
    @State private var cancellations = 0

    var body: some View {
        VStack {
            Button("Open test example") { showingExample = true }
            Text("Cancelled requests: \(cancellations)")
            Text(viewModel.isLoading ? "Provider running" : "Provider idle")
            Text(viewModel.errorMessage ?? "No generation error")
            Text(viewModel.lastGeneratedContent == nil ? "No generated result" : "Unexpected result")
        }
        .sheet(isPresented: $showingExample) {
            ExampleDetailView(
                exampleType: .recipes,
                viewModel: viewModel,
                generationOverride: { prompt in
                    let _: String? = await viewModel.generate(prompt: prompt, publish: { text in
                        viewModel.lastGeneratedContent = text
                    }, operation: {
                        // Long enough that test success requires cancellation, not natural completion.
                        try await Task.sleep(for: .seconds(60))
                        return "Unexpected delayed result"
                    })
                    if Task.isCancelled { cancellations += 1 }
                }
            )
        }
    }
}
#endif
