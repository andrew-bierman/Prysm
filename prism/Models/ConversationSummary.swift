//
//  ConversationSummary.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import Foundation
import FoundationModels

@Generable
struct ConversationSummary {
    @Guide(
        description:
            "A comprehensive summary of the entire conversation including all key points, topics discussed, questions asked, and responses provided. Include important context and details that would help continue the conversation naturally."
    )
    let summary: String

    @Guide(description: "The main topics or themes that were discussed in the conversation")
    let keyTopics: [String]

    @Guide(
        description: "Any specific requests, preferences, or important information the user mentioned")
    let userPreferences: [String]
}