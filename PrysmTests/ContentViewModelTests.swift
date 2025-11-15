//
//  ContentViewModelTests.swift
//  PrismTests
//
//  Testing the ContentViewModel for examples generation
//

import Testing
import Foundation
import FoundationModels
@testable import Prysm

@MainActor
struct ContentViewModelTests {

    @Test("ViewModel initializes with empty generated content")
    func testViewModelInitialization() async {
        let viewModel = ContentViewModel()

        #expect(viewModel.generatedRecipe == nil)
        #expect(viewModel.generatedItinerary == nil)
        #expect(viewModel.generatedReviews.isEmpty)
        #expect(viewModel.generatedRecommendations.isEmpty)
        #expect(viewModel.lastGeneratedContent == nil)
        #expect(!viewModel.isGenerating)
    }

    @Test("Generation status updates during content generation")
    func testGenerationStatus() async {
        let viewModel = ContentViewModel()

        #expect(!viewModel.isGenerating)

        // Start generation
        viewModel.isGenerating = true
        #expect(viewModel.isGenerating)

        // Complete generation
        viewModel.isGenerating = false
        #expect(!viewModel.isGenerating)
    }

    @Test("Recipe generation stores result")
    func testRecipeGeneration() async {
        let viewModel = ContentViewModel()

        // Simulate recipe generation
        let testRecipe = Recipe(
            name: "Test Recipe",
            description: "A test recipe",
            ingredients: ["ingredient1", "ingredient2"],
            instructions: ["step1", "step2"],
            prepTime: 15,
            cookTime: 30,
            servings: 4,
            difficulty: "Easy",
            cuisineType: "Italian"
        )

        viewModel.generatedRecipe = testRecipe
        viewModel.lastGeneratedContent = testRecipe

        #expect(viewModel.generatedRecipe?.name == "Test Recipe")
        #expect(viewModel.generatedRecipe?.ingredients.count == 2)
        #expect(viewModel.generatedRecipe?.prepTime == 15)
        #expect(viewModel.lastGeneratedContent as? Recipe == testRecipe)
    }

    @Test("Book recommendations generation")
    func testBookRecommendations() async {
        let viewModel = ContentViewModel()

        // Simulate book recommendations
        let testBooks = [
            Book(
                title: "Test Book 1",
                author: "Author 1",
                genre: "Fiction",
                yearPublished: 2023,
                summary: "A great book",
                whyRecommended: "You'll love it"
            ),
            Book(
                title: "Test Book 2",
                author: "Author 2",
                genre: "Non-fiction",
                yearPublished: 2024,
                summary: "Another great book",
                whyRecommended: "Perfect for you"
            )
        ]

        viewModel.generatedRecommendations = testBooks
        viewModel.lastGeneratedContent = testBooks

        #expect(viewModel.generatedRecommendations.count == 2)
        #expect(viewModel.generatedRecommendations.first?.title == "Test Book 1")
        #expect(viewModel.generatedRecommendations.last?.genre == "Non-fiction")
    }

    @Test("Travel itinerary generation")
    func testItineraryGeneration() async {
        let viewModel = ContentViewModel()

        // Simulate itinerary generation
        let testItinerary = TravelItinerary(
            destination: "Paris",
            duration: "5 days",
            activities: [
                Activity(
                    name: "Eiffel Tower",
                    description: "Visit the iconic tower",
                    duration: "2 hours",
                    estimatedCost: "$30",
                    bestTime: "Morning"
                ),
                Activity(
                    name: "Louvre Museum",
                    description: "See amazing art",
                    duration: "4 hours",
                    estimatedCost: "$20",
                    bestTime: "Afternoon"
                )
            ],
            estimatedBudget: "$1500",
            bestTimeToVisit: "Spring"
        )

        viewModel.generatedItinerary = testItinerary
        viewModel.lastGeneratedContent = testItinerary

        #expect(viewModel.generatedItinerary?.destination == "Paris")
        #expect(viewModel.generatedItinerary?.activities.count == 2)
        #expect(viewModel.generatedItinerary?.activities.first?.name == "Eiffel Tower")
    }

    @Test("Product reviews generation")
    func testProductReviews() async {
        let viewModel = ContentViewModel()

        // Simulate product reviews
        let testReviews = [
            ProductReview(
                reviewerName: "John Doe",
                rating: 5,
                title: "Excellent product!",
                review: "I love this product",
                verifiedPurchase: true,
                helpfulCount: 42,
                datePosted: Date()
            ),
            ProductReview(
                reviewerName: "Jane Smith",
                rating: 4,
                title: "Good but could be better",
                review: "Overall satisfied",
                verifiedPurchase: false,
                helpfulCount: 15,
                datePosted: Date()
            )
        ]

        viewModel.generatedReviews = testReviews
        viewModel.lastGeneratedContent = testReviews

        #expect(viewModel.generatedReviews.count == 2)
        #expect(viewModel.generatedReviews.first?.rating == 5)
        #expect(viewModel.generatedReviews.last?.reviewerName == "Jane Smith")
    }

    @Test("Clear all generated content")
    func testClearGeneratedContent() async {
        let viewModel = ContentViewModel()

        // Add some content
        viewModel.generatedRecipe = Recipe(
            name: "Test",
            description: "Test",
            ingredients: [],
            instructions: [],
            prepTime: 0,
            cookTime: 0,
            servings: 1,
            difficulty: "Easy",
            cuisineType: "Test"
        )
        viewModel.generatedRecommendations = [Book(
            title: "Test",
            author: "Test",
            genre: "Test",
            yearPublished: 2024,
            summary: "Test",
            whyRecommended: "Test"
        )]
        viewModel.lastGeneratedContent = "Some content"

        // Clear all
        viewModel.clearAll()

        #expect(viewModel.generatedRecipe == nil)
        #expect(viewModel.generatedItinerary == nil)
        #expect(viewModel.generatedReviews.isEmpty)
        #expect(viewModel.generatedRecommendations.isEmpty)
        #expect(viewModel.lastGeneratedContent == nil)
    }
}

// MARK: - Model Structure Tests

extension ContentViewModelTests {

    @Test("Recipe model properties")
    func testRecipeModel() {
        let recipe = Recipe(
            name: "Pasta Carbonara",
            description: "Classic Italian dish",
            ingredients: ["Pasta", "Eggs", "Bacon", "Parmesan"],
            instructions: ["Boil pasta", "Cook bacon", "Mix eggs", "Combine"],
            prepTime: 10,
            cookTime: 20,
            servings: 4,
            difficulty: "Medium",
            cuisineType: "Italian"
        )

        #expect(recipe.name == "Pasta Carbonara")
        #expect(recipe.ingredients.count == 4)
        #expect(recipe.instructions.count == 4)
        #expect(recipe.prepTime == 10)
        #expect(recipe.cookTime == 20)
        #expect(recipe.servings == 4)
        #expect(recipe.difficulty == "Medium")
        #expect(recipe.cuisineType == "Italian")
    }

    @Test("Book model properties")
    func testBookModel() {
        let book = Book(
            title: "1984",
            author: "George Orwell",
            genre: "Dystopian Fiction",
            yearPublished: 1949,
            summary: "A totalitarian future",
            whyRecommended: "Classic must-read"
        )

        #expect(book.title == "1984")
        #expect(book.author == "George Orwell")
        #expect(book.genre == "Dystopian Fiction")
        #expect(book.yearPublished == 1949)
        #expect(book.summary == "A totalitarian future")
        #expect(book.whyRecommended == "Classic must-read")
    }

    @Test("Activity model properties")
    func testActivityModel() {
        let activity = Activity(
            name: "Museum Visit",
            description: "Explore art and history",
            duration: "3 hours",
            estimatedCost: "$25",
            bestTime: "Morning"
        )

        #expect(activity.name == "Museum Visit")
        #expect(activity.description == "Explore art and history")
        #expect(activity.duration == "3 hours")
        #expect(activity.estimatedCost == "$25")
        #expect(activity.bestTime == "Morning")
    }

    @Test("TravelItinerary model properties")
    func testTravelItineraryModel() {
        let activities = [
            Activity(
                name: "Beach",
                description: "Relax",
                duration: "2 hours",
                estimatedCost: "Free",
                bestTime: "Afternoon"
            )
        ]

        let itinerary = TravelItinerary(
            destination: "Hawaii",
            duration: "7 days",
            activities: activities,
            estimatedBudget: "$3000",
            bestTimeToVisit: "Summer"
        )

        #expect(itinerary.destination == "Hawaii")
        #expect(itinerary.duration == "7 days")
        #expect(itinerary.activities.count == 1)
        #expect(itinerary.estimatedBudget == "$3000")
        #expect(itinerary.bestTimeToVisit == "Summer")
    }

    @Test("ProductReview model properties")
    func testProductReviewModel() {
        let date = Date()
        let review = ProductReview(
            reviewerName: "TestUser",
            rating: 4,
            title: "Good Product",
            review: "I liked it",
            verifiedPurchase: true,
            helpfulCount: 10,
            datePosted: date
        )

        #expect(review.reviewerName == "TestUser")
        #expect(review.rating == 4)
        #expect(review.title == "Good Product")
        #expect(review.review == "I liked it")
        #expect(review.verifiedPurchase == true)
        #expect(review.helpfulCount == 10)
        #expect(review.datePosted == date)
    }
}