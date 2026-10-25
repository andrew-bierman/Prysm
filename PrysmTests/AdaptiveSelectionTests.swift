import SwiftUI
import Testing
@testable import Prysm

@MainActor
struct AdaptiveSelectionTests {
    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("Assistant selection survives reconstruction with the parent's binding")
    func assistantSelection() {
        var selection = 1
        let binding = Binding(get: { selection }, set: { selection = $0 })
        let compact = AssistantView(selectedTab: binding, onEditInstructions: {})
        compact.selectedTab = 2
        let expanded = AssistantView(selectedTab: binding, onEditInstructions: {})
        #expect(expanded.selectedTab == 2)
        expanded.selectedTab = 0
        #expect(compact.selectedTab == 0)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("Model selection survives reconstruction with the parent's binding")
    func modelSelection() {
        var selection = 0
        let binding = Binding(get: { selection }, set: { selection = $0 })
        let compact = ModelView(selectedTab: binding)
        compact.selectedTab = 1
        #expect(ModelView(selectedTab: binding).selectedTab == 1)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("Instructions edit requests presentation from the stable parent")
    func instructionsPresentation() {
        var presented = false
        let view = AssistantView(selectedTab: .constant(2)) { presented = true }
        view.onEditInstructions()
        #expect(presented)
    }
}
