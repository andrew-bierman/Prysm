//
//  InstructionsSheet.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import SwiftUI
import FoundationModels

struct InstructionsSheet: View {
    @Binding var isPresented: Bool
    @AppStorage("customInstructions") private var customInstructions = ""
    @AppStorage("useCustomInstructions") private var useCustomInstructions = false
    @State private var editingInstructions = ""
    @FocusState private var isTextFieldFocused: Bool

    private let samplePrompts = [
        ("Professional", "Please provide clear, professional responses with a formal tone."),
        ("Creative", "Be creative and imaginative in your responses. Use metaphors and vivid descriptions."),
        ("Concise", "Keep responses brief and to the point. Avoid unnecessary elaboration."),
        ("Teacher", "Explain concepts clearly as if teaching. Break down complex ideas into simple parts."),
        ("Friendly", "Be warm and conversational. Use a casual, friendly tone."),
        ("Technical", "Provide detailed technical explanations with precision and accuracy.")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.large) {
                    headerSection

                    toggleSection

                    if useCustomInstructions {
                        instructionsEditor
                        samplePromptsSection
                    }

                    infoSection
                }
                .padding()
            }
            .navigationTitle("Custom Instructions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveInstructions()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            editingInstructions = customInstructions
            if useCustomInstructions && customInstructions.isEmpty {
                isTextFieldFocused = true
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Label("Customize AI Behavior", systemImage: "wand.and.stars")
                .font(.headline)

            Text("Set custom instructions to guide how the AI responds to you")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var toggleSection: some View {
        Toggle(isOn: $useCustomInstructions) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Enable Custom Instructions")
                    .font(.subheadline)
                Text("Apply these instructions to all conversations")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }

    private var instructionsEditor: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            HStack {
                Text("Your Instructions")
                    .font(.headline)
                Spacer()
                Text("\(editingInstructions.count) characters")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            TextEditor(text: $editingInstructions)
                .focused($isTextFieldFocused)
                .font(.body)
                .padding(8)
                .frame(minHeight: 150)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.medium)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
        }
    }

    private var samplePromptsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text("Sample Instructions")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.small) {
                    ForEach(samplePrompts, id: \.0) { sample in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                editingInstructions = sample.1
                            }
                        } label: {
                            Text(sample.0)
                                .font(.caption)
                                .padding(.horizontal, Spacing.medium)
                                .padding(.vertical, Spacing.small)
                                .background(Color.accentColor.opacity(0.1))
                                .foregroundStyle(.primary)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if !editingInstructions.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.xSmall) {
                    Text("Preview")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(editingInstructions)
                        .font(.caption)
                        .padding(Spacing.small)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.accentColor.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
                        .lineLimit(3)
                }
            }
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Label("How it works", systemImage: "info.circle")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Your custom instructions will be automatically included with every message you send. The AI will follow these guidelines to tailor its responses to your preferences.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }

    private func saveInstructions() {
        customInstructions = editingInstructions.trimmingCharacters(in: .whitespacesAndNewlines)
        isPresented = false
    }
}

#Preview {
    InstructionsSheet(isPresented: .constant(true))
}