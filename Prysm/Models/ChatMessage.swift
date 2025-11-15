//
//  ChatMessage.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import Foundation
import FoundationModels

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let entryID: Transcript.Entry.ID?
    let content: AttributedString
    let isFromUser: Bool
    let timestamp: Date
    let isContextSummary: Bool

    init(content: String, isFromUser: Bool, isContextSummary: Bool = false) {
        self.init(entryID: nil, content: content, isFromUser: isFromUser, isContextSummary: isContextSummary)
    }

    init(entryID: Transcript.Entry.ID?, content: String, isFromUser: Bool, isContextSummary: Bool = false) {
        self.id = UUID()
        self.entryID = entryID
        self.content = AttributedString(content)
        self.isFromUser = isFromUser
        self.timestamp = Date()
        self.isContextSummary = isContextSummary
    }

    init(content: AttributedString, isFromUser: Bool, isContextSummary: Bool = false) {
        self.id = UUID()
        self.entryID = nil
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = Date()
        self.isContextSummary = isContextSummary
    }
}