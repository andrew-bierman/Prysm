//
//  ContentViewModelTests.swift
//  PrysmTests
//
//  Testing the ContentViewModel for examples generation
//

import Testing
import Foundation
import FoundationModels
@testable import Prysm

@MainActor
@Suite("ContentViewModel Tests")
struct ContentViewModelTests {

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("Unavailable model blocks every example without generating")
    func testUnavailableExamples() async {
        let viewModel = ContentViewModel(modelAvailability: { .unavailable(.modelNotReady) })
        await viewModel.generateRecipe(prompt: "Dinner")
        #expect(viewModel.generatedRecipe == nil)
        await viewModel.generateBookRecommendation(prompt: "Fiction")
        await viewModel.generateTravelItinerary(prompt: "Paris")
        await viewModel.generateStory(prompt: "Mystery")
        await viewModel.generateBusinessIdea(prompt: "Design")
        await viewModel.generateEmail(prompt: "Follow up")
        await viewModel.generateProductReview(prompt: "Headphones")
        let response = await viewModel.generateQuickResponse(prompt: "Hello")
        #expect(response == nil)
        #expect(viewModel.lastGeneratedContent == nil)
        #expect(viewModel.errorMessage?.contains("downloading") == true)
        #expect(!viewModel.isLoading)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("Unavailable reasons explain the recovery action")
    func testUnavailableReasons() async {
        let reasons: [(SystemLanguageModel.Availability.UnavailableReason, String)] = [
            (.deviceNotEligible, "not supported"),
            (.appleIntelligenceNotEnabled, "Settings"),
            (.modelNotReady, "downloading")
        ]
        for (reason, message) in reasons {
            let viewModel = ContentViewModel(modelAvailability: { .unavailable(reason) })
            var called = false
            let result = await viewModel.generate(prompt: "Hello") {
                called = true
                return "Unexpected"
            }
            #expect(!called)
            #expect(result == nil)
            #expect(viewModel.errorMessage?.contains(message) == true)
        }
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("Blank and overlapping requests preserve the current state")
    func testRejectedRequests() async {
        let viewModel = ContentViewModel(modelAvailability: { .available })
        viewModel.lastGeneratedContent = "Previous"
        var called = false
        let blank = await viewModel.generate(prompt: " \n\t") {
            called = true
            return "Unexpected"
        }
        #expect(blank == nil)
        #expect(!called)
        #expect(viewModel.lastGeneratedContent as? String == "Previous")

        let first = await viewModel.generate(prompt: "First") {
            #expect(viewModel.isLoading)
            let second = await viewModel.generate(prompt: "Second") {
                called = true
                return "Unexpected"
            }
            #expect(second == nil)
            #expect(viewModel.isLoading)
            return "First result"
        }
        #expect(first == "First result")
        #expect(!called)
        #expect(!viewModel.isLoading)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("Availability is rechecked and old results and errors are cleared")
    func testAvailabilityRecovery() async {
        var availability: SystemLanguageModel.Availability = .unavailable(.modelNotReady)
        let viewModel = ContentViewModel(modelAvailability: { availability })
        let blocked = await viewModel.generate(prompt: "Hello") { "Unexpected" }
        #expect(blocked == nil)
        availability = .available
        viewModel.lastGeneratedContent = "Stale result"
        let result = await viewModel.generate(prompt: "Hello") {
            #expect(viewModel.lastGeneratedContent == nil)
            #expect(viewModel.errorMessage == nil)
            return "Recovered"
        }
        #expect(result == "Recovered")
        #expect(!viewModel.isLoading)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("Failure resets loading and permits retry")
    func testFailureAndRetry() async {
        struct Failure: LocalizedError {
            var errorDescription: String? { "Test failure" }
        }
        let viewModel = ContentViewModel(modelAvailability: { .available })
        let result: String? = await viewModel.generate(prompt: "Hello") { throw Failure() }
        #expect(result == nil)
        #expect(viewModel.errorMessage == "Test failure")
        #expect(!viewModel.isLoading)
        let retry = await viewModel.generate(prompt: "Hello") { "Success" }
        #expect(retry == "Success")
        #expect(viewModel.errorMessage == nil)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("Cancellation is silent and resets loading")
    func testCancellation() async {
        let viewModel = ContentViewModel(modelAvailability: { .available })
        let result: String? = await viewModel.generate(prompt: "Hello") {
            throw CancellationError()
        }
        #expect(result == nil)
        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.isLoading)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("Late completion after cancellation is discarded")
    func testLateCancelledCompletion() async {
        let viewModel = ContentViewModel(modelAvailability: { .available })
        let task = Task { @MainActor in
            await viewModel.generate(prompt: "Hello") {
                withUnsafeCurrentTask { $0?.cancel() }
                return "Late result"
            }
        }
        let result = await task.value
        #expect(result == nil)
        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.isLoading)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("Clearing suspended generation discards its result and error", arguments: [false, true])
    func testClearSuspendedGeneration(fails: Bool) async {
        let viewModel = ContentViewModel(modelAvailability: { .available })
        let started = AsyncStream<Void>.makeStream()
        var continuation: CheckedContinuation<String, Error>?
        var published = false
        let task = Task { @MainActor in
            await viewModel.generate(prompt: "Hello", publish: { _ in
                published = true
            }, operation: {
                try await withCheckedThrowingContinuation { pending in
                    continuation = pending
                    started.continuation.yield(())
                    started.continuation.finish()
                }
            })
        }
        for await _ in started.stream { break }
        #expect(viewModel.isLoading)
        viewModel.clearResults()
        if fails {
            continuation?.resume(throwing: NSError(domain: "test", code: 1))
        } else {
            continuation?.resume(returning: "Obsolete")
        }
        let result = await task.value
        #expect(result == nil)
        #expect(!published)
        #expect(viewModel.lastGeneratedContent == nil)
        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.isLoading)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("Caller cancellation discards a suspended provider's completion", arguments: [false, true])
    func testCallerCancellation(fails: Bool) async {
        let viewModel = ContentViewModel(modelAvailability: { .available })
        let started = AsyncStream<Void>.makeStream()
        var continuation: CheckedContinuation<String, Error>?
        var published = false
        let task = Task { @MainActor in
            await viewModel.generate(prompt: "Hello", publish: { _ in
                published = true
            }, operation: {
                try await withCheckedThrowingContinuation { pending in
                    continuation = pending
                    started.continuation.yield(())
                    started.continuation.finish()
                }
            })
        }
        for await _ in started.stream { break }
        var overlappingOperationCalled = false
        let overlap = await viewModel.generate(prompt: "Second") {
            overlappingOperationCalled = true
            return "Unexpected"
        }
        #expect(overlap == nil)
        #expect(!overlappingOperationCalled)
        #expect(viewModel.isLoading)
        task.cancel()
        if fails {
            continuation?.resume(throwing: NSError(domain: "test", code: 2))
        } else {
            continuation?.resume(returning: "Too late")
        }
        let result = await task.value
        #expect(result == nil)
        #expect(!published)
        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.isLoading)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("Typed old result is cleared and new result publishes while guarded")
    func testTypedResultReplacement() async {
        let viewModel = ContentViewModel(modelAvailability: { .available })
        viewModel.generatedRecipe = Recipe(
            name: "Old", cuisine: "Test", difficulty: .easy,
            prepTimeMinutes: 1, servings: 1, ingredients: [], instructions: []
        )
        viewModel.lastGeneratedContent = viewModel.generatedRecipe
        let result: String? = await viewModel.generate(prompt: "New", publish: { text in
            #expect(viewModel.isLoading)
            #expect(viewModel.generatedRecipe == nil)
            viewModel.lastGeneratedContent = text
        }, operation: {
            #expect(viewModel.generatedRecipe == nil)
            return "Replacement"
        })
        #expect(result == "Replacement")
        #expect(viewModel.lastGeneratedContent as? String == "Replacement")
        #expect(!viewModel.isLoading)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("ViewModel initializes with empty generated content")
    func testViewModelInitialization() async {
        let viewModel = ContentViewModel()

        #expect(viewModel.generatedRecipe == nil)
        #expect(viewModel.generatedBook == nil)
        #expect(viewModel.generatedItinerary == nil)
        #expect(viewModel.generatedStory == nil)
        #expect(viewModel.generatedBusiness == nil)
        #expect(viewModel.generatedEmail == nil)
        #expect(viewModel.generatedReview == nil)
        #expect(viewModel.lastGeneratedContent == nil)
        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.isLoading)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("Loading status can be toggled")
    func testLoadingStatus() async {
        let viewModel = ContentViewModel()

        #expect(!viewModel.isLoading)

        viewModel.isLoading = true
        #expect(viewModel.isLoading)

        viewModel.isLoading = false
        #expect(!viewModel.isLoading)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("Recipe can be stored on view model")
    func testRecipeStorage() async {
        let viewModel = ContentViewModel()

        let testRecipe = Recipe(
            name: "Test Recipe",
            cuisine: "Italian",
            difficulty: .easy,
            prepTimeMinutes: 15,
            servings: 4,
            ingredients: ["ingredient1", "ingredient2"],
            instructions: ["step1", "step2"]
        )

        viewModel.generatedRecipe = testRecipe
        viewModel.lastGeneratedContent = testRecipe

        #expect(viewModel.generatedRecipe?.name == "Test Recipe")
        #expect(viewModel.generatedRecipe?.cuisine == "Italian")
        #expect(viewModel.generatedRecipe?.difficulty == .easy)
        #expect(viewModel.generatedRecipe?.prepTimeMinutes == 15)
        #expect(viewModel.generatedRecipe?.servings == 4)
        #expect(viewModel.generatedRecipe?.ingredients.count == 2)
        #expect(viewModel.generatedRecipe?.instructions.count == 2)
        #expect(viewModel.lastGeneratedContent != nil)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("BookRecommendation can be stored on view model")
    func testBookRecommendationStorage() async {
        let viewModel = ContentViewModel()

        let testBook = BookRecommendation(
            title: "1984",
            author: "George Orwell",
            description: "A dystopian novel",
            genre: .fiction,
            recommendation: "Classic must-read"
        )

        viewModel.generatedBook = testBook
        viewModel.lastGeneratedContent = testBook

        #expect(viewModel.generatedBook?.title == "1984")
        #expect(viewModel.generatedBook?.author == "George Orwell")
        #expect(viewModel.generatedBook?.description == "A dystopian novel")
        #expect(viewModel.generatedBook?.genre == .fiction)
        #expect(viewModel.generatedBook?.recommendation == "Classic must-read")
        #expect(viewModel.lastGeneratedContent != nil)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("TravelItinerary can be stored on view model")
    func testItineraryStorage() async {
        let viewModel = ContentViewModel()

        let testItinerary = TravelItinerary(
            destination: "Paris",
            duration: 5,
            budget: .moderate,
            activities: [
                DayPlan(
                    day: 1,
                    morning: "Visit the Eiffel Tower",
                    afternoon: "Explore the Louvre",
                    evening: "Dinner on the Seine"
                ),
                DayPlan(
                    day: 2,
                    morning: "Montmartre walk",
                    afternoon: "Notre-Dame area",
                    evening: "Cabaret show"
                )
            ],
            accommodations: ["Hotel Le Marais", "Airbnb in Montmartre"]
        )

        viewModel.generatedItinerary = testItinerary
        viewModel.lastGeneratedContent = testItinerary

        #expect(viewModel.generatedItinerary?.destination == "Paris")
        #expect(viewModel.generatedItinerary?.duration == 5)
        #expect(viewModel.generatedItinerary?.budget == .moderate)
        #expect(viewModel.generatedItinerary?.activities.count == 2)
        #expect(viewModel.generatedItinerary?.activities.first?.day == 1)
        #expect(viewModel.generatedItinerary?.activities.first?.morning == "Visit the Eiffel Tower")
        #expect(viewModel.generatedItinerary?.accommodations.count == 2)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("StoryOutline can be stored on view model")
    func testStoryStorage() async {
        let viewModel = ContentViewModel()

        let testStory = StoryOutline(
            title: "The Last Algorithm",
            protagonist: "Ada, a brilliant software engineer",
            conflict: "An AI threatens to replace all human creativity",
            setting: "San Francisco, 2035",
            genre: .sciFi,
            themes: ["technology", "creativity", "humanity"]
        )

        viewModel.generatedStory = testStory
        viewModel.lastGeneratedContent = testStory

        #expect(viewModel.generatedStory?.title == "The Last Algorithm")
        #expect(viewModel.generatedStory?.protagonist == "Ada, a brilliant software engineer")
        #expect(viewModel.generatedStory?.genre == .sciFi)
        #expect(viewModel.generatedStory?.themes.count == 3)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("BusinessIdea can be stored on view model")
    func testBusinessIdeaStorage() async {
        let viewModel = ContentViewModel()

        let testBusiness = BusinessIdea(
            name: "EcoDeliver",
            description: "Sustainable last-mile delivery service",
            targetMarket: "Urban eco-conscious consumers",
            revenueModel: "Per-delivery fee plus subscription",
            advantages: ["Zero emissions", "Faster than traditional delivery"],
            estimatedStartupCost: "$50,000",
            timeline: "6 months to launch"
        )

        viewModel.generatedBusiness = testBusiness
        viewModel.lastGeneratedContent = testBusiness

        #expect(viewModel.generatedBusiness?.name == "EcoDeliver")
        #expect(viewModel.generatedBusiness?.targetMarket == "Urban eco-conscious consumers")
        #expect(viewModel.generatedBusiness?.advantages.count == 2)
        #expect(viewModel.generatedBusiness?.timeline == "6 months to launch")
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("EmailDraft can be stored on view model")
    func testEmailStorage() async {
        let viewModel = ContentViewModel()

        let testEmail = EmailDraft(
            subject: "Meeting Follow-Up",
            greeting: "Dear Team,",
            body: "Thank you for attending the meeting.",
            closing: "Best regards",
            tone: .professional
        )

        viewModel.generatedEmail = testEmail
        viewModel.lastGeneratedContent = testEmail

        #expect(viewModel.generatedEmail?.subject == "Meeting Follow-Up")
        #expect(viewModel.generatedEmail?.tone == .professional)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("ProductReview can be stored on view model")
    func testProductReviewStorage() async {
        let viewModel = ContentViewModel()

        let testReview = ProductReview(
            productName: "Wireless Headphones",
            rating: 4,
            reviewText: "Great sound quality and comfortable fit.",
            wouldRecommend: true,
            pros: ["Sound quality", "Comfort", "Battery life"],
            cons: ["Price", "No wired option"]
        )

        viewModel.generatedReview = testReview
        viewModel.lastGeneratedContent = testReview

        #expect(viewModel.generatedReview?.productName == "Wireless Headphones")
        #expect(viewModel.generatedReview?.rating == 4)
        #expect(viewModel.generatedReview?.wouldRecommend == true)
        #expect(viewModel.generatedReview?.pros.count == 3)
        #expect(viewModel.generatedReview?.cons.count == 2)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("clearResults resets all generated content")
    func testClearResults() async {
        let viewModel = ContentViewModel()

        // Populate some content
        viewModel.generatedRecipe = Recipe(
            name: "Test",
            cuisine: "Test",
            difficulty: .easy,
            prepTimeMinutes: 0,
            servings: 1,
            ingredients: [],
            instructions: []
        )
        viewModel.generatedBook = BookRecommendation(
            title: "Test",
            author: "Test",
            description: "Test",
            genre: .fiction,
            recommendation: "Test"
        )
        viewModel.errorMessage = "Some error"
        viewModel.lastGeneratedContent = "Some content"

        // Clear all
        viewModel.clearResults()

        #expect(viewModel.generatedRecipe == nil)
        #expect(viewModel.generatedBook == nil)
        #expect(viewModel.generatedItinerary == nil)
        #expect(viewModel.generatedStory == nil)
        #expect(viewModel.generatedBusiness == nil)
        #expect(viewModel.generatedEmail == nil)
        #expect(viewModel.generatedReview == nil)
        #expect(viewModel.lastGeneratedContent == nil)
        #expect(viewModel.errorMessage == nil)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("Error message can be set and cleared")
    func testErrorMessage() async {
        let viewModel = ContentViewModel()

        #expect(viewModel.errorMessage == nil)

        viewModel.errorMessage = "Something went wrong"
        #expect(viewModel.errorMessage == "Something went wrong")

        viewModel.clearResults()
        #expect(viewModel.errorMessage == nil)
    }
}

// MARK: - Model Structure Tests

@Suite("Data Model Tests")
struct DataModelTests {

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("Recipe model properties")
    func testRecipeModel() {
        let recipe = Recipe(
            name: "Pasta Carbonara",
            cuisine: "Italian",
            difficulty: .medium,
            prepTimeMinutes: 30,
            servings: 4,
            ingredients: ["Pasta", "Eggs", "Bacon", "Parmesan"],
            instructions: ["Boil pasta", "Cook bacon", "Mix eggs", "Combine"]
        )

        #expect(recipe.name == "Pasta Carbonara")
        #expect(recipe.cuisine == "Italian")
        #expect(recipe.difficulty == .medium)
        #expect(recipe.prepTimeMinutes == 30)
        #expect(recipe.servings == 4)
        #expect(recipe.ingredients.count == 4)
        #expect(recipe.instructions.count == 4)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("RecipeDifficulty enum values")
    func testRecipeDifficulty() {
        #expect(RecipeDifficulty.easy.rawValue == "easy")
        #expect(RecipeDifficulty.medium.rawValue == "medium")
        #expect(RecipeDifficulty.hard.rawValue == "hard")
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("BookRecommendation model properties")
    func testBookRecommendationModel() {
        let book = BookRecommendation(
            title: "1984",
            author: "George Orwell",
            description: "A dystopian novel",
            genre: .fiction,
            recommendation: "Classic must-read"
        )

        #expect(book.title == "1984")
        #expect(book.author == "George Orwell")
        #expect(book.description == "A dystopian novel")
        #expect(book.genre == .fiction)
        #expect(book.recommendation == "Classic must-read")
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("BookGenre enum values")
    func testBookGenre() {
        #expect(BookGenre.fiction.rawValue == "fiction")
        #expect(BookGenre.nonFiction.rawValue == "nonFiction")
        #expect(BookGenre.mystery.rawValue == "mystery")
        #expect(BookGenre.sciFi.rawValue == "sciFi")
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("DayPlan model properties")
    func testDayPlanModel() {
        let dayPlan = DayPlan(
            day: 1,
            morning: "Breakfast tour",
            afternoon: "Museum visit",
            evening: "Dinner show"
        )

        #expect(dayPlan.day == 1)
        #expect(dayPlan.morning == "Breakfast tour")
        #expect(dayPlan.afternoon == "Museum visit")
        #expect(dayPlan.evening == "Dinner show")
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("TravelItinerary model properties")
    func testTravelItineraryModel() {
        let itinerary = TravelItinerary(
            destination: "Hawaii",
            duration: 7,
            budget: .luxury,
            activities: [
                DayPlan(day: 1, morning: "Beach", afternoon: "Snorkel", evening: "Luau")
            ],
            accommodations: ["Resort on Waikiki"]
        )

        #expect(itinerary.destination == "Hawaii")
        #expect(itinerary.duration == 7)
        #expect(itinerary.budget == .luxury)
        #expect(itinerary.activities.count == 1)
        #expect(itinerary.accommodations.count == 1)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("TravelBudget enum values")
    func testTravelBudget() {
        #expect(TravelBudget.budget.rawValue == "budget")
        #expect(TravelBudget.moderate.rawValue == "moderate")
        #expect(TravelBudget.luxury.rawValue == "luxury")
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("StoryOutline model properties")
    func testStoryOutlineModel() {
        let story = StoryOutline(
            title: "The Quest",
            protagonist: "A brave knight",
            conflict: "A dragon threatens the kingdom",
            setting: "Medieval fantasy world",
            genre: .fantasy,
            themes: ["courage", "sacrifice"]
        )

        #expect(story.title == "The Quest")
        #expect(story.protagonist == "A brave knight")
        #expect(story.conflict == "A dragon threatens the kingdom")
        #expect(story.setting == "Medieval fantasy world")
        #expect(story.genre == .fantasy)
        #expect(story.themes.count == 2)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("BusinessIdea model properties with optional timeline")
    func testBusinessIdeaModel() {
        let ideaWithTimeline = BusinessIdea(
            name: "TestBiz",
            description: "A test business",
            targetMarket: "Everyone",
            revenueModel: "Subscription",
            advantages: ["Fast", "Cheap"],
            estimatedStartupCost: "$10,000",
            timeline: "3 months"
        )

        #expect(ideaWithTimeline.name == "TestBiz")
        #expect(ideaWithTimeline.advantages.count == 2)
        #expect(ideaWithTimeline.timeline == "3 months")

        let ideaWithoutTimeline = BusinessIdea(
            name: "TestBiz2",
            description: "Another business",
            targetMarket: "Developers",
            revenueModel: "Freemium",
            advantages: ["Open source"],
            estimatedStartupCost: "$5,000",
            timeline: nil
        )

        #expect(ideaWithoutTimeline.timeline == nil)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("ProductReview model properties")
    func testProductReviewModel() {
        let review = ProductReview(
            productName: "Widget Pro",
            rating: 5,
            reviewText: "Outstanding product with great features.",
            wouldRecommend: true,
            pros: ["Durable", "Affordable"],
            cons: ["Limited colors"]
        )

        #expect(review.productName == "Widget Pro")
        #expect(review.rating == 5)
        #expect(review.reviewText == "Outstanding product with great features.")
        #expect(review.wouldRecommend == true)
        #expect(review.pros.count == 2)
        #expect(review.cons.count == 1)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("EmailDraft model properties")
    func testEmailDraftModel() {
        let email = EmailDraft(
            subject: "Hello",
            greeting: "Hi there,",
            body: "Just checking in.",
            closing: "Cheers",
            tone: .casual
        )

        #expect(email.subject == "Hello")
        #expect(email.greeting == "Hi there,")
        #expect(email.body == "Just checking in.")
        #expect(email.closing == "Cheers")
        #expect(email.tone == .casual)
    }

    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @Test("EmailTone enum values")
    func testEmailTone() {
        #expect(EmailTone.formal.rawValue == "formal")
        #expect(EmailTone.casual.rawValue == "casual")
        #expect(EmailTone.friendly.rawValue == "friendly")
        #expect(EmailTone.professional.rawValue == "professional")
    }
}
