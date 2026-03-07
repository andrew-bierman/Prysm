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
        #expect(!viewModel.isLoading)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Loading status tracking")
    func testLoadingStatus() async {
        let viewModel = ContentViewModel()

        #expect(!viewModel.isLoading)

        viewModel.isLoading = true
        #expect(viewModel.isLoading)

        viewModel.isLoading = false
        #expect(!viewModel.isLoading)
    }

    @Test("Clear all generated content")
    func testClearResults() async {
        let viewModel = ContentViewModel()

        // Set some error state
        viewModel.errorMessage = "Test error"

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

    @Test("Error message tracking")
    func testErrorMessage() async {
        let viewModel = ContentViewModel()

        #expect(viewModel.errorMessage == nil)

        viewModel.errorMessage = "Something went wrong"
        #expect(viewModel.errorMessage == "Something went wrong")

        viewModel.clearResults()
        #expect(viewModel.errorMessage == nil)
    }
}
