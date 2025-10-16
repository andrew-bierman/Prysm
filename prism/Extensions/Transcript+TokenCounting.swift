//
//  Transcript+TokenCounting.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import Foundation
import FoundationModels

extension Transcript.Entry {
    var estimatedTokenCount: Int {
        switch self {
        case .instructions(let instructions):
            return instructions.segments.reduce(0) { $0 + $1.estimatedTokenCount }

        case .prompt(let prompt):
            return prompt.segments.reduce(0) { $0 + $1.estimatedTokenCount }

        case .response(let response):
            return response.segments.reduce(0) { $0 + $1.estimatedTokenCount }

        case .toolCalls(let toolCalls):
            return toolCalls.reduce(0) { total, call in
                total + estimateTokens(call.toolName) + 10
            }

        case .toolOutput(let output):
            return output.segments.reduce(0) { $0 + $1.estimatedTokenCount } + 3
        @unknown default:
            fatalError()
        }
    }
}

extension Transcript.Segment {
    var estimatedTokenCount: Int {
        switch self {
        case .text(let textSegment):
            return estimateTokens(textSegment.content)

        case .structure(let structuredSegment):
            return estimateTokensForStructured(structuredSegment.content)
        @unknown default:
            fatalError()
        }
    }
}

extension Transcript {
    var estimatedTokenCount: Int {
        return self.reduce(0) { $0 + $1.estimatedTokenCount }
    }
}

func estimateTokens(_ text: String) -> Int {
    guard !text.isEmpty else { return 0 }
    let characterCount = text.count
    let tokensPerChar = 1.0 / 4.5
    return max(1, Int(ceil(Double(characterCount) * tokensPerChar)))
}

func estimateTokensForStructured(_ content: GeneratedContent) -> Int {
    let jsonString = content.jsonString
    let characterCount = jsonString.count
    let tokensPerChar = 1.0 / 4.5
    return max(1, Int(ceil(Double(characterCount) * tokensPerChar)))
}

extension Transcript {
    var safeEstimatedTokenCount: Int {
        let baseTokens = estimatedTokenCount
        let buffer = Int(Double(baseTokens) * 0.25)
        let systemOverhead = 100
        return baseTokens + buffer + systemOverhead
    }

    func isApproachingLimit(threshold: Double = 0.70, maxTokens: Int = 4096) -> Bool {
        let currentTokens = safeEstimatedTokenCount
        let limitThreshold = Int(Double(maxTokens) * threshold)
        return currentTokens > limitThreshold
    }

    func entriesWithinTokenBudget(_ budget: Int) -> [Transcript.Entry] {
        var result: [Transcript.Entry] = []
        var tokenCount = 0

        if let instructions = self.first(where: {
            if case .instructions = $0 { return true }
            return false
        }) {
            result.append(instructions)
            tokenCount += instructions.estimatedTokenCount
        }

        let nonInstructionEntries = self.filter { entry in
            if case .instructions = entry { return false }
            return true
        }

        for entry in nonInstructionEntries.reversed() {
            let entryTokens = entry.estimatedTokenCount
            if tokenCount + entryTokens > budget { break }

            result.insert(entry, at: result.count)
            tokenCount += entryTokens
        }

        return result
    }
}