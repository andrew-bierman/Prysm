//
//  ContentViewModel.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import Foundation
import FoundationModels
import Observation

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

    @MainActor
    func generateRecipe(prompt: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let session = LanguageModelSession()
            let response = try await session.respond(
                to: Prompt(prompt),
                generating: Recipe.self
            )
            generatedRecipe = response.content
            lastGeneratedContent = response.content
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    func generateBookRecommendation(prompt: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let session = LanguageModelSession()
            let response = try await session.respond(
                to: Prompt(prompt),
                generating: BookRecommendation.self
            )
            generatedBook = response.content
            lastGeneratedContent = response.content
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    func generateTravelItinerary(prompt: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let session = LanguageModelSession()
            let response = try await session.respond(
                to: Prompt(prompt),
                generating: TravelItinerary.self
            )
            generatedItinerary = response.content
            lastGeneratedContent = response.content
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    func generateStory(prompt: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let session = LanguageModelSession()
            let response = try await session.respond(
                to: Prompt(prompt),
                generating: StoryOutline.self
            )
            generatedStory = response.content
            lastGeneratedContent = response.content
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    func generateBusinessIdea(prompt: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let session = LanguageModelSession()
            let response = try await session.respond(
                to: Prompt(prompt),
                generating: BusinessIdea.self
            )
            generatedBusiness = response.content
            lastGeneratedContent = response.content
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    func generateEmail(prompt: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let session = LanguageModelSession()
            let response = try await session.respond(
                to: Prompt(prompt),
                generating: EmailDraft.self
            )
            generatedEmail = response.content
            lastGeneratedContent = response.content
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    func generateProductReview(prompt: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let session = LanguageModelSession()
            let response = try await session.respond(
                to: Prompt(prompt),
                generating: ProductReview.self
            )
            generatedReview = response.content
            lastGeneratedContent = response.content
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    func generateQuickResponse(prompt: String) async -> String? {
        isLoading = true
        errorMessage = nil

        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: Prompt(prompt))
            let text = response.content
            lastGeneratedContent = text
            isLoading = false
            return text
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return nil
        }
    }

    @MainActor
    func clearResults() {
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