//
//  DataModels.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import Foundation
import FoundationModels

// MARK: - Book Recommendation Models

@Generable
struct BookRecommendation {
    @Guide(description: "The title of the book")
    let title: String

    @Guide(description: "The author's name")
    let author: String

    @Guide(description: "A brief description in 2-3 sentences")
    let description: String

    @Guide(description: "Genre of the book")
    let genre: BookGenre

    @Guide(description: "Why this book is recommended")
    let recommendation: String
}

@Generable
enum BookGenre: String {
    case fiction
    case nonFiction
    case mystery
    case romance
    case sciFi
    case fantasy
    case biography
    case history
}

// MARK: - Recipe Models

@Generable
struct Recipe {
    @Guide(description: "Name of the recipe")
    let name: String

    @Guide(description: "Type of cuisine")
    let cuisine: String

    @Guide(description: "Difficulty level")
    let difficulty: RecipeDifficulty

    @Guide(description: "Preparation time in minutes")
    let prepTimeMinutes: Int

    @Guide(description: "Number of servings")
    let servings: Int

    @Guide(description: "List of ingredients with quantities")
    let ingredients: [String]

    @Guide(description: "Step-by-step cooking instructions")
    let instructions: [String]
}

@Generable
enum RecipeDifficulty: String {
    case easy
    case medium
    case hard
}

// MARK: - Travel Planning Models

@Generable
struct TravelItinerary {
    @Guide(description: "Destination city or country")
    let destination: String

    @Guide(description: "Duration in days")
    let duration: Int

    @Guide(description: "Budget range")
    let budget: TravelBudget

    @Guide(description: "Daily activities and attractions")
    let activities: [DayPlan]

    @Guide(description: "Recommended accommodations")
    let accommodations: [String]
}

@Generable
struct DayPlan {
    @Guide(description: "Day number")
    let day: Int

    @Guide(description: "Morning activity")
    let morning: String

    @Guide(description: "Afternoon activity")
    let afternoon: String

    @Guide(description: "Evening activity")
    let evening: String
}

@Generable
enum TravelBudget: String {
    case budget
    case moderate
    case luxury
}

// MARK: - Creative Writing Models

@Generable
struct StoryOutline {
    @Guide(description: "The title of the story")
    let title: String

    @Guide(description: "Main character name and brief description")
    let protagonist: String

    @Guide(description: "The central conflict or challenge")
    let conflict: String

    @Guide(description: "The setting where the story takes place")
    let setting: String

    @Guide(description: "Story genre")
    let genre: StoryGenre

    @Guide(description: "Major themes explored in the story")
    let themes: [String]
}

@Generable
enum StoryGenre: String {
    case adventure
    case mystery
    case romance
    case thriller
    case fantasy
    case sciFi
    case horror
    case comedy
}

// MARK: - Business Models

@Generable
struct BusinessIdea {
    @Guide(description: "Name of the business")
    let name: String

    @Guide(description: "Brief description of what the business does")
    let description: String

    @Guide(description: "Target market or customer base")
    let targetMarket: String

    @Guide(description: "Primary revenue model")
    let revenueModel: String

    @Guide(description: "Key advantages or unique selling points")
    let advantages: [String]

    @Guide(description: "Initial startup costs estimate")
    let estimatedStartupCost: String

    @Guide(description: "Expected timeline or phases for launch and growth")
    let timeline: String?
}

// MARK: - Product Review Models

@Generable
struct ProductReview {
    @Guide(description: "Product name")
    let productName: String

    @Guide(description: "Rating from 1 to 5")
    let rating: Int

    @Guide(description: "Review text between 50-200 words")
    let reviewText: String

    @Guide(description: "Would recommend this product")
    let wouldRecommend: Bool

    @Guide(description: "Key pros of the product")
    let pros: [String]

    @Guide(description: "Key cons of the product")
    let cons: [String]
}

// MARK: - Email Models

@Generable
struct EmailDraft {
    @Guide(description: "Email subject line")
    let subject: String

    @Guide(description: "Greeting or salutation")
    let greeting: String

    @Guide(description: "Main body of the email")
    let body: String

    @Guide(description: "Closing or sign-off")
    let closing: String

    @Guide(description: "Tone of the email")
    let tone: EmailTone
}

@Generable
enum EmailTone: String {
    case formal
    case casual
    case friendly
    case professional
}