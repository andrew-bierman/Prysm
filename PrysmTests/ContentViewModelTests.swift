//
//  ContentViewModelTests.swift
//  PrysmTests
//
//  Testing the ContentViewModel for examples generation
//

import Testing
import Foundation
@testable import Prysm

@MainActor
@Suite("ContentViewModel Tests")
struct ContentViewModelTests {

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

    @Test("Loading status can be toggled")
    func testLoadingStatus() async {
        let viewModel = ContentViewModel()

        #expect(!viewModel.isLoading)

        viewModel.isLoading = true
        #expect(viewModel.isLoading)

        viewModel.isLoading = false
        #expect(!viewModel.isLoading)
    }

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

    @Test("RecipeDifficulty enum values")
    func testRecipeDifficulty() {
        #expect(RecipeDifficulty.easy.rawValue == "easy")
        #expect(RecipeDifficulty.medium.rawValue == "medium")
        #expect(RecipeDifficulty.hard.rawValue == "hard")
    }

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

    @Test("BookGenre enum values")
    func testBookGenre() {
        #expect(BookGenre.fiction.rawValue == "fiction")
        #expect(BookGenre.nonFiction.rawValue == "nonFiction")
        #expect(BookGenre.mystery.rawValue == "mystery")
        #expect(BookGenre.sciFi.rawValue == "sciFi")
    }

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

    @Test("TravelBudget enum values")
    func testTravelBudget() {
        #expect(TravelBudget.budget.rawValue == "budget")
        #expect(TravelBudget.moderate.rawValue == "moderate")
        #expect(TravelBudget.luxury.rawValue == "luxury")
    }

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

    @Test("EmailTone enum values")
    func testEmailTone() {
        #expect(EmailTone.formal.rawValue == "formal")
        #expect(EmailTone.casual.rawValue == "casual")
        #expect(EmailTone.friendly.rawValue == "friendly")
        #expect(EmailTone.professional.rawValue == "professional")
    }
}
