//
//  ExampleType.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import Foundation
import SwiftUI

enum ExampleType: String, CaseIterable, Identifiable {
    case recipes = "recipes"
    case bookRecommendations = "book_recommendations"
    case travelPlanning = "travel_planning"
    case creativeWriting = "creative_writing"
    case businessIdeas = "business_ideas"
    case emailDrafts = "email_drafts"
    case productReviews = "product_reviews"
    case quickChat = "quick_chat"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .recipes:
            return "Recipe Ideas"
        case .bookRecommendations:
            return "Book Finder"
        case .travelPlanning:
            return "Travel Planner"
        case .creativeWriting:
            return "Story Creator"
        case .businessIdeas:
            return "Business Ideas"
        case .emailDrafts:
            return "Email Writer"
        case .productReviews:
            return "Review Generator"
        case .quickChat:
            return "Quick Chat"
        }
    }

    var subtitle: String {
        switch self {
        case .recipes:
            return "Get personalized recipe suggestions"
        case .bookRecommendations:
            return "Discover your next great read"
        case .travelPlanning:
            return "Plan your perfect trip"
        case .creativeWriting:
            return "Generate story ideas and outlines"
        case .businessIdeas:
            return "Brainstorm startup concepts"
        case .emailDrafts:
            return "Draft professional emails"
        case .productReviews:
            return "Create detailed product reviews"
        case .quickChat:
            return "Quick questions and answers"
        }
    }

    var icon: String {
        switch self {
        case .recipes:
            return "frying.pan"
        case .bookRecommendations:
            return "book"
        case .travelPlanning:
            return "airplane"
        case .creativeWriting:
            return "pencil.and.outline"
        case .businessIdeas:
            return "lightbulb"
        case .emailDrafts:
            return "envelope"
        case .productReviews:
            return "star.leadinghalf.filled"
        case .quickChat:
            return "bubble.left.and.bubble.right"
        }
    }

    var accentColor: Color {
        switch self {
        case .recipes:
            return .orange
        case .bookRecommendations:
            return .purple
        case .travelPlanning:
            return .blue
        case .creativeWriting:
            return .pink
        case .businessIdeas:
            return .green
        case .emailDrafts:
            return .indigo
        case .productReviews:
            return .yellow
        case .quickChat:
            return .cyan
        }
    }
}