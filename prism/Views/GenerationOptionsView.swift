//
//  GenerationOptionsView.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import SwiftUI
import FoundationModels

struct GenerationOptionsView: View {
    @AppStorage("temperature") private var temperature: Double = 0.7
    @AppStorage("topP") private var topP: Double = 0.95
    @AppStorage("maxTokens") private var maxTokens: Int = 2048
    @AppStorage("streamResponses") private var streamResponses: Bool = true
    @AppStorage("autoSummarize") private var autoSummarize: Bool = true
    @AppStorage("contextWindowSize") private var contextWindowSize: Int = 4096

    @State private var showingResetConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.large) {
                headerView

                temperatureSection
                topPSection
                tokensSection
                behaviorSection

                resetButton
            }
            .padding()
        }
        .navigationTitle("Generation Options")
#if os(iOS)
        .navigationBarTitleDisplayMode(.large)
#endif
        .confirmationDialog("Reset to Defaults?", isPresented: $showingResetConfirmation) {
            Button("Reset", role: .destructive) {
                resetToDefaults()
            }
        } message: {
            Text("This will reset all generation options to their default values.")
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("Fine-tune AI Responses")
                .font(.title2)
                .bold()

            Text("Adjust how the AI generates responses to match your preferences")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var temperatureSection: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Label("Creativity", systemImage: "sparkles")
                .font(.headline)

            Text("Higher values make responses more creative and varied")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: Spacing.small) {
                HStack {
                    Text("Conservative")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.1f", temperature))
                        .font(.caption.monospaced())
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("Creative")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Slider(value: $temperature, in: 0...2, step: 0.1)
                    .tint(.purple)
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        }
    }

    private var topPSection: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Label("Focus", systemImage: "target")
                .font(.headline)

            Text("Controls the diversity of word choices")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: Spacing.small) {
                HStack {
                    Text("Narrow")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.2f", topP))
                        .font(.caption.monospaced())
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("Broad")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Slider(value: $topP, in: 0.1...1.0, step: 0.05)
                    .tint(.blue)
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        }
    }

    private var tokensSection: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Label("Response Length", systemImage: "text.alignleft")
                .font(.headline)

            Text("Maximum tokens per response")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: Spacing.small) {
                HStack {
                    Text("Short")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(maxTokens)")
                        .font(.caption.monospaced())
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("Long")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Slider(value: Binding(
                    get: { Double(maxTokens) },
                    set: { maxTokens = Int($0) }
                ), in: 256...8192, step: 256)
                    .tint(.green)
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        }
    }

    private var behaviorSection: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Label("Behavior", systemImage: "gearshape")
                .font(.headline)

            VStack(spacing: 0) {
                Toggle(isOn: $streamResponses) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Stream Responses")
                            .font(.subheadline)
                        Text("Show responses as they're generated")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()

                Divider()

                Toggle(isOn: $autoSummarize) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Auto-Summarize")
                            .font(.subheadline)
                        Text("Automatically summarize long conversations")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()

                Divider()

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Context Window")
                            .font(.subheadline)
                        Text("\(contextWindowSize) tokens")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Stepper("", value: $contextWindowSize, in: 1024...16384, step: 1024)
                        .labelsHidden()
                }
                .padding()
            }
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        }
    }

    private var resetButton: some View {
        Button {
            showingResetConfirmation = true
        } label: {
            Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .padding(.top)
    }

    private func resetToDefaults() {
        temperature = 0.7
        topP = 0.95
        maxTokens = 2048
        streamResponses = true
        autoSummarize = true
        contextWindowSize = 4096
    }
}

#Preview {
    NavigationStack {
        GenerationOptionsView()
    }
}