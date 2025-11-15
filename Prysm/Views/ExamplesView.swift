//
//  ExamplesView.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import SwiftUI
import FoundationModels

struct ExamplesView: View {
    @State private var viewModel = ContentViewModel()
    @State private var selectedExample: ExampleType?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.large) {
                headerView
                exampleGrid
                if viewModel.isLoading {
                    loadingView
                }
            }
            .padding()
        }
        .navigationTitle("Examples")
#if os(iOS)
        .navigationBarTitleDisplayMode(.large)
#endif
        .sheet(item: $selectedExample) { example in
            ExampleDetailView(exampleType: example, viewModel: viewModel)
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("Explore AI Capabilities")
                .font(.title2)
                .bold()

            Text("Try these examples to see what \(AppConfig.appName) can do")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var exampleGrid: some View {
        LazyVGrid(columns: adaptiveGridColumns, spacing: Spacing.large) {
            ForEach(ExampleType.allCases) { example in
                Button {
                    selectedExample = example
                } label: {
                    ExampleCard(example: example)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var adaptiveGridColumns: [GridItem] {
#if os(iOS)
        return [
            GridItem(.flexible(minimum: 150), spacing: Spacing.medium),
            GridItem(.flexible(minimum: 150), spacing: Spacing.medium)
        ]
#else
        return [
            GridItem(.adaptive(minimum: 200, maximum: 300), spacing: Spacing.large)
        ]
#endif
    }

    private var loadingView: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Generating...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial, in: Capsule())
    }
}

struct ExampleCard: View {
    let example: ExampleType

    var body: some View {
        VStack(spacing: Spacing.medium) {
            Image(systemName: example.icon)
                .font(.largeTitle)
                .foregroundStyle(example.accentColor)
                .frame(height: 50)

            VStack(spacing: Spacing.xSmall) {
                Text(example.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text(example.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .stroke(example.accentColor.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ExampleDetailView: View {
    let exampleType: ExampleType
    let viewModel: ContentViewModel
    @State private var prompt = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.large) {
                    // Input section
                    VStack(alignment: .leading, spacing: Spacing.medium) {
                        Text("What would you like?")
                            .font(.headline)

                        TextField(placeholderText, text: $prompt, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                    }
                    .padding()

                    // Generate button
                    Button {
                        Task {
                            await generateContent()
                        }
                    } label: {
                        Label("Generate", systemImage: "sparkles")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(prompt.isEmpty || viewModel.isLoading)
                    .padding(.horizontal)

                    // Results section
                    if viewModel.lastGeneratedContent != nil {
                        resultView
                    }

                    // Loading indicator
                    if viewModel.isLoading {
                        HStack {
                            ProgressView()
                            Text("Generating...")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }

                    // Error display
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                            .padding()
                    }
                }
            }
            .navigationTitle(exampleType.title)
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var placeholderText: String {
        switch exampleType {
        case .recipes:
            return "E.g., A healthy dinner recipe with chicken and vegetables"
        case .bookRecommendations:
            return "E.g., Science fiction books similar to Dune"
        case .travelPlanning:
            return "E.g., 5-day trip to Tokyo on a moderate budget"
        case .creativeWriting:
            return "E.g., A mystery story set in a haunted library"
        case .businessIdeas:
            return "E.g., Online business ideas for creative professionals"
        case .emailDrafts:
            return "E.g., Follow-up email after job interview"
        case .productReviews:
            return "E.g., Review for noise-canceling headphones"
        case .quickChat:
            return "Ask me anything..."
        }
    }

    @ViewBuilder
    private var resultView: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text("Result")
                .font(.headline)
                .padding(.horizontal)

            ScrollView {
                // Display based on type
                if let recipe = viewModel.generatedRecipe {
                    RecipeResultView(recipe: recipe)
                } else if let book = viewModel.generatedBook {
                    BookResultView(book: book)
                } else if let itinerary = viewModel.generatedItinerary {
                    TravelResultView(itinerary: itinerary)
                } else if let story = viewModel.generatedStory {
                    StoryResultView(story: story)
                } else if let business = viewModel.generatedBusiness {
                    BusinessResultView(business: business)
                } else if let email = viewModel.generatedEmail {
                    EmailResultView(email: email)
                } else if let review = viewModel.generatedReview {
                    ReviewResultView(review: review)
                } else if let text = viewModel.lastGeneratedContent as? String {
                    Text(text)
                        .padding()
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .padding()
    }

    private func generateContent() async {
        switch exampleType {
        case .recipes:
            await viewModel.generateRecipe(prompt: prompt)
        case .bookRecommendations:
            await viewModel.generateBookRecommendation(prompt: prompt)
        case .travelPlanning:
            await viewModel.generateTravelItinerary(prompt: prompt)
        case .creativeWriting:
            await viewModel.generateStory(prompt: prompt)
        case .businessIdeas:
            await viewModel.generateBusinessIdea(prompt: prompt)
        case .emailDrafts:
            await viewModel.generateEmail(prompt: prompt)
        case .productReviews:
            await viewModel.generateProductReview(prompt: prompt)
        case .quickChat:
            _ = await viewModel.generateQuickResponse(prompt: prompt)
        }
    }
}

// MARK: - Result Views

struct RecipeResultView: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text(recipe.name)
                .font(.title2)
                .bold()

            HStack {
                Label("\(recipe.prepTimeMinutes) min", systemImage: "clock")
                Label("\(recipe.servings) servings", systemImage: "person.2")
                Label(recipe.difficulty.rawValue.capitalized, systemImage: "star")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("Ingredients")
                    .font(.headline)
                ForEach(recipe.ingredients, id: \.self) { ingredient in
                    Text("• \(ingredient)")
                        .font(.body)
                }
            }

            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("Instructions")
                    .font(.headline)
                ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                    Text("\(index + 1). \(instruction)")
                        .font(.body)
                }
            }
        }
        .padding()
    }
}

struct BookResultView: View {
    let book: BookRecommendation

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text(book.title)
                .font(.title2)
                .bold()

            Text("by \(book.author)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Label(book.genre.rawValue.capitalized, systemImage: "bookmark")
                .font(.caption)

            Text(book.description)
                .font(.body)

            Text("Why this book?")
                .font(.headline)
            Text(book.recommendation)
                .font(.body)
        }
        .padding()
    }
}

struct TravelResultView: View {
    let itinerary: TravelItinerary

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text("\(itinerary.destination)")
                .font(.title2)
                .bold()

            HStack {
                Label("\(itinerary.duration) days", systemImage: "calendar")
                Label(itinerary.budget.rawValue.capitalized, systemImage: "dollarsign.circle")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            ForEach(itinerary.activities, id: \.day) { dayPlan in
                VStack(alignment: .leading, spacing: Spacing.xSmall) {
                    Text("Day \(dayPlan.day)")
                        .font(.headline)
                    Text("Morning: \(dayPlan.morning)")
                    Text("Afternoon: \(dayPlan.afternoon)")
                    Text("Evening: \(dayPlan.evening)")
                }
                .font(.body)
            }

            if !itinerary.accommodations.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.xSmall) {
                    Text("Recommended Accommodations")
                        .font(.headline)
                    ForEach(itinerary.accommodations, id: \.self) { place in
                        Text("• \(place)")
                    }
                }
            }
        }
        .padding()
    }
}

struct StoryResultView: View {
    let story: StoryOutline

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text(story.title)
                .font(.title2)
                .bold()

            Label(story.genre.rawValue.capitalized, systemImage: "book.closed")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("Protagonist")
                    .font(.headline)
                Text(story.protagonist)
            }

            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("Setting")
                    .font(.headline)
                Text(story.setting)
            }

            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("Conflict")
                    .font(.headline)
                Text(story.conflict)
            }

            if !story.themes.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("Themes")
                        .font(.headline)
                    ForEach(story.themes, id: \.self) { theme in
                        Text("• \(theme)")
                    }
                }
            }
        }
        .padding()
    }
}

struct BusinessResultView: View {
    let business: BusinessIdea

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text(business.name)
                .font(.title2)
                .bold()

            Text(business.description)
                .font(.body)

            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("Target Market")
                    .font(.headline)
                Text(business.targetMarket)
            }

            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("Revenue Model")
                    .font(.headline)
                Text(business.revenueModel)
            }

            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("Startup Cost")
                    .font(.headline)
                Text(business.estimatedStartupCost)
            }

            if !business.advantages.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("Key Advantages")
                        .font(.headline)
                    ForEach(business.advantages, id: \.self) { advantage in
                        Text("• \(advantage)")
                    }
                }
            }

            if let timeline = business.timeline {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("Timeline")
                        .font(.headline)
                    Text(timeline)
                }
            }
        }
        .padding()
    }
}

struct EmailResultView: View {
    let email: EmailDraft

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            HStack {
                Text("Subject:")
                    .font(.headline)
                Text(email.subject)
            }

            Divider()

            Text(email.greeting)
                .font(.body)

            Text(email.body)
                .font(.body)
                .padding(.vertical, Spacing.small)

            Text(email.closing)
                .font(.body)

            Label("Tone: \(email.tone.rawValue.capitalized)", systemImage: "text.bubble")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

struct ReviewResultView: View {
    let review: ProductReview

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            HStack {
                Text(review.productName)
                    .font(.title2)
                    .bold()
                Spacer()
                HStack(spacing: Spacing.xSmall / 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= review.rating ? "star.fill" : "star")
                            .foregroundStyle(.yellow)
                    }
                }
            }

            Text(review.reviewText)
                .font(.body)

            if !review.pros.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Label("Pros", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.green)
                    ForEach(review.pros, id: \.self) { pro in
                        Text("• \(pro)")
                    }
                }
            }

            if !review.cons.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Label("Cons", systemImage: "minus.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.red)
                    ForEach(review.cons, id: \.self) { con in
                        Text("• \(con)")
                    }
                }
            }

            HStack {
                Image(systemName: review.wouldRecommend ? "checkmark.circle.fill" : "xmark.circle")
                    .foregroundStyle(review.wouldRecommend ? .green : .red)
                Text(review.wouldRecommend ? "Would Recommend" : "Would Not Recommend")
                    .font(.caption)
                    .bold()
            }
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        ExamplesView()
    }
}