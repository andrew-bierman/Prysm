import Foundation
import FoundationModels

@Generable
struct RecipeRecommendation: Sendable {
    var name: String
    var cuisine: String
    var difficulty: DifficultyLevel
    var prepTimeMinutes: Int
    var servings: Int
    var ingredients: [String]
    var instructions: [String]
    var nutritionFacts: NutritionInfo?

    enum DifficultyLevel: String, CaseIterable, Sendable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
    }

    @Generable
    struct NutritionInfo: Sendable {
        var calories: Int
        var protein: Double
        var carbs: Double
        var fat: Double
    }
}

@Generable
struct CodeAnalysis: Sendable {
    var language: String
    var complexity: ComplexityRating
    var lineCount: Int
    var functions: [FunctionInfo]
    var suggestions: [String]
    var hasTests: Bool
    var testCoverage: Double?

    enum ComplexityRating: String, CaseIterable, Sendable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case veryHigh = "Very High"
    }

    @Generable
    struct FunctionInfo: Sendable {
        var name: String
        var parameters: [String]
        var returnType: String?
        var complexity: Int
        var linesOfCode: Int
    }
}

@Generable
struct TravelItinerary: Sendable {
    var destination: String
    var duration: Int
    var budget: BudgetRange
    var activities: [Activity]
    var accommodations: [Accommodation]
    var transportOptions: [String]
    var weatherForecast: String?

    enum BudgetRange: String, CaseIterable, Sendable {
        case budget = "Budget"
        case moderate = "Moderate"
        case luxury = "Luxury"
    }

    @Generable
    struct Activity: Sendable {
        var name: String
        var description: String
        var duration: Int
        var cost: Double?
        var category: String
        var bestTime: String?
    }

    @Generable
    struct Accommodation: Sendable {
        var name: String
        var type: String
        var pricePerNight: Double
        var rating: Double?
        var amenities: [String]
    }
}