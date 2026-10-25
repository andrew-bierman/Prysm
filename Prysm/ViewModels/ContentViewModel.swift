//
//  ContentViewModel.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import Foundation
import FoundationModels
import Observation

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
@MainActor
@Observable
final class ContentViewModel {
    var isLoading = false
    var errorMessage: String?
    var lastGeneratedContent: Any?

    // For displaying results
    var generatedRecipe: Recipe?
    var generatedBook: BookRecommendation?
    var generatedItinerary: TravelItinerary?
    var generatedStory: StoryOutline?
    var generatedBusiness: BusinessIdea?
    var generatedEmail: EmailDraft?
    var generatedReview: ProductReview?

    private var resultRevision = UUID()

    private let modelAvailability: @MainActor () -> SystemLanguageModel.Availability

    init(modelAvailability: @escaping @MainActor () -> SystemLanguageModel.Availability = {
        SystemLanguageModel.default.availability
    }) {
        self.modelAvailability = modelAvailability
    }

    /// Serializes requests and checks availability each time, including after Settings changes.
    /// The operation seam lets lifecycle tests run without invoking the on-device model.
    @MainActor
    func generate<Value>(
        prompt: String,
        publish: @MainActor (Value) -> Void = { _ in },
        operation: @MainActor () async throws -> Value
    ) async -> Value? {
        guard !isLoading, !Task.isCancelled,
              !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        clearResults()
        let revision = resultRevision

        switch modelAvailability() {
        case .available:
            break
        case .unavailable(let reason):
            switch reason {
            case .deviceNotEligible:
                errorMessage = "Apple Intelligence is not supported on this device."
            case .appleIntelligenceNotEnabled:
                errorMessage = "Enable Apple Intelligence in Settings to generate content."
            case .modelNotReady:
                errorMessage = "Apple Intelligence is still downloading. Try again when it is ready."
            @unknown default:
                errorMessage = "Apple Intelligence is currently unavailable. Please try again later."
            }
            return nil
        }

        isLoading = true
        defer { isLoading = false }
        do {
            let value = try await operation()
            // A provider may complete even after its caller has cancelled.
            try Task.checkCancellation()
            guard revision == resultRevision else { return nil }
            // Publish before releasing the loading guard, without another suspension.
            publish(value)
            return value
        } catch is CancellationError {
            return nil
        } catch {
            if !Task.isCancelled, revision == resultRevision {
                errorMessage = error.localizedDescription
            }
            return nil
        }
    }

    @MainActor
    func generateRecipe(prompt: String) async {
        _ = await generate(prompt: prompt, publish: { content in
            self.generatedRecipe = content
            self.lastGeneratedContent = content
        }, operation: {
            let session = LanguageModelSession()
            return try await session.respond(to: Prompt(prompt), generating: Recipe.self).content
        })
    }

    @MainActor
    func generateBookRecommendation(prompt: String) async {
        _ = await generate(prompt: prompt, publish: { content in
            self.generatedBook = content
            self.lastGeneratedContent = content
        }, operation: {
            let session = LanguageModelSession()
            return try await session.respond(to: Prompt(prompt), generating: BookRecommendation.self).content
        })
    }

    @MainActor
    func generateTravelItinerary(prompt: String) async {
        _ = await generate(prompt: prompt, publish: { content in
            self.generatedItinerary = content
            self.lastGeneratedContent = content
        }, operation: {
            let session = LanguageModelSession()
            return try await session.respond(to: Prompt(prompt), generating: TravelItinerary.self).content
        })
    }

    @MainActor
    func generateStory(prompt: String) async {
        _ = await generate(prompt: prompt, publish: { content in
            self.generatedStory = content
            self.lastGeneratedContent = content
        }, operation: {
            let session = LanguageModelSession()
            return try await session.respond(to: Prompt(prompt), generating: StoryOutline.self).content
        })
    }

    @MainActor
    func generateBusinessIdea(prompt: String) async {
        _ = await generate(prompt: prompt, publish: { content in
            self.generatedBusiness = content
            self.lastGeneratedContent = content
        }, operation: {
            let session = LanguageModelSession()
            return try await session.respond(to: Prompt(prompt), generating: BusinessIdea.self).content
        })
    }

    @MainActor
    func generateEmail(prompt: String) async {
        _ = await generate(prompt: prompt, publish: { content in
            self.generatedEmail = content
            self.lastGeneratedContent = content
        }, operation: {
            let session = LanguageModelSession()
            return try await session.respond(to: Prompt(prompt), generating: EmailDraft.self).content
        })
    }

    @MainActor
    func generateProductReview(prompt: String) async {
        _ = await generate(prompt: prompt, publish: { content in
            self.generatedReview = content
            self.lastGeneratedContent = content
        }, operation: {
            let session = LanguageModelSession()
            return try await session.respond(to: Prompt(prompt), generating: ProductReview.self).content
        })
    }

    @MainActor
    func generateQuickResponse(prompt: String) async -> String? {
        return await generate(prompt: prompt, publish: { text in
            self.lastGeneratedContent = text
        }, operation: {
            let session = LanguageModelSession()
            return try await session.respond(to: Prompt(prompt)).content
        })
    }

    @MainActor
    func clearResults() {
        resultRevision = UUID()
        generatedRecipe = nil
        generatedBook = nil
        generatedItinerary = nil
        generatedStory = nil
        generatedBusiness = nil
        generatedEmail = nil
        generatedReview = nil
        lastGeneratedContent = nil
        errorMessage = nil
    }
}