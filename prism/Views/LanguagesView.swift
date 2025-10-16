//
//  LanguagesView.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import SwiftUI
import FoundationModels

struct LanguagesView: View {
    @AppStorage("selectedLanguageModel") private var selectedModel = "default"
    @State private var availableModels: [LanguageModelInfo] = []
    @State private var isCheckingModels = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.large) {
                headerView

                if isCheckingModels {
                    ProgressView("Checking available models...")
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if availableModels.isEmpty {
                    emptyStateView
                } else {
                    modelsList
                }
            }
            .padding()
        }
        .navigationTitle("Language Models")
#if os(iOS)
        .navigationBarTitleDisplayMode(.large)
#endif
        .task {
            await checkAvailableModels()
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("Choose Your AI Model")
                .font(.title2)
                .bold()

            Text("Select the language model that best fits your needs")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: Spacing.medium) {
            Image(systemName: "brain")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No models available")
                .font(.headline)

            Text("Language models will appear here when available")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xLarge * 2)
    }

    private var modelsList: some View {
        VStack(spacing: Spacing.medium) {
            ForEach(availableModels) { model in
                ModelCard(
                    model: model,
                    isSelected: selectedModel == model.id,
                    action: {
                        selectedModel = model.id
                    }
                )
            }
        }
    }

    private func checkAvailableModels() async {
        isCheckingModels = true

        // Simulate checking for available models
        // In a real app, this would query the FoundationModels framework
        await MainActor.run {
            availableModels = [
                LanguageModelInfo(
                    id: "default",
                    name: "On-Device Model",
                    description: "Apple's privacy-focused language model",
                    capabilities: ["Fast responses", "Privacy-focused", "Offline capable"],
                    icon: "cpu",
                    accentColor: .blue
                ),
                LanguageModelInfo(
                    id: "cloudPro",
                    name: "Cloud Pro Model",
                    description: "Advanced cloud-based model for complex tasks",
                    capabilities: ["Internet access", "Latest information", "Extended context"],
                    icon: "cloud.fill",
                    accentColor: .purple,
                    isPremium: true
                )
            ]
            isCheckingModels = false
        }
    }
}

struct LanguageModelInfo: Identifiable {
    let id: String
    let name: String
    let description: String
    let capabilities: [String]
    let icon: String
    let accentColor: Color
    var isPremium: Bool = false
}

struct ModelCard: View {
    let model: LanguageModelInfo
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack {
                    Image(systemName: model.icon)
                        .font(.largeTitle)
                        .foregroundStyle(model.accentColor)

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.green)
                    }

                    if model.isPremium {
                        Label("Premium", systemImage: "star.fill")
                            .font(.caption)
                            .padding(.horizontal, Spacing.small)
                            .padding(.vertical, Spacing.xSmall)
                            .background(model.accentColor.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }

                VStack(alignment: .leading, spacing: Spacing.xSmall) {
                    Text(model.name)
                        .font(.headline)

                    Text(model.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if !model.capabilities.isEmpty {
                    HStack(spacing: Spacing.small) {
                        ForEach(model.capabilities.prefix(3), id: \.self) { capability in
                            Text(capability)
                                .font(.caption)
                                .padding(.horizontal, Spacing.small)
                                .padding(.vertical, Spacing.xSmall)
                                .background(.secondary.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? model.accentColor.opacity(0.1) : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.CornerRadius.large)
                    .stroke(isSelected ? model.accentColor : Color.secondary.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Spacing.CornerRadius.large))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        LanguagesView()
    }
}