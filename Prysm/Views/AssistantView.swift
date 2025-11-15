//
//  AssistantView.swift
//  Prism
//
//  Configure assistant behavior and capabilities
//

import SwiftUI

struct AssistantView: View {
    @State private var selectedTab = 0
    @AppStorage("useCustomInstructions") private var useCustomInstructions = false
    @AppStorage("customInstructions") private var customInstructions = ""
    @State private var showingInstructionsSheet = false

    var body: some View {
        VStack(spacing: 0) {
            // Segmented picker for sub-sections
            Picker("Assistant Configuration", selection: $selectedTab) {
                Text("Examples").tag(0)
                Text("Tools").tag(1)
                Text("Instructions").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()

            // Content based on selection
            switch selectedTab {
            case 0:
                ExamplesView()
            case 1:
                ToolsView()
            case 2:
                instructionsView
            default:
                ExamplesView()
            }
        }
        .navigationTitle("Assistant")
#if os(iOS)
        .navigationBarTitleDisplayMode(.large)
#endif
        .sheet(isPresented: $showingInstructionsSheet) {
            InstructionsSheet(isPresented: $showingInstructionsSheet)
        }
    }

    private var instructionsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.large) {
                // Header
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Label("Custom Instructions", systemImage: "text.alignleft")
                        .font(.title2)
                        .bold()

                    Text("Personalize how the AI responds to you")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.top)

                // Instructions toggle and preview
                VStack(spacing: Spacing.medium) {
                    Toggle(isOn: $useCustomInstructions) {
                        VStack(alignment: .leading, spacing: Spacing.xSmall) {
                            Text("Enable Custom Instructions")
                                .font(.headline)
                            Text("Apply personalized instructions to all conversations")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))

                    if useCustomInstructions {
                        VStack(alignment: .leading, spacing: Spacing.medium) {
                            HStack {
                                Text("Current Instructions")
                                    .font(.headline)
                                Spacer()
                                Button("Edit") {
                                    showingInstructionsSheet = true
                                }
                                .buttonStyle(.bordered)
                            }

                            if customInstructions.isEmpty {
                                Text("No instructions set. Tap Edit to add your preferences.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.secondary.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
                            } else {
                                Text(customInstructions)
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color.accentColor.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
                            }
                        }
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
                    }

                    // Quick templates
                    VStack(alignment: .leading, spacing: Spacing.medium) {
                        Text("Quick Templates")
                            .font(.headline)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: Spacing.medium) {
                            ForEach(instructionTemplates, id: \.name) { template in
                                Button {
                                    customInstructions = template.instructions
                                    useCustomInstructions = true
                                } label: {
                                    VStack(alignment: .leading, spacing: Spacing.small) {
                                        Label(template.name, systemImage: template.icon)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text(template.description)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(.regularMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding()
                }
                .padding(.horizontal)
            }
        }
    }
}

struct InstructionTemplate {
    let name: String
    let icon: String
    let description: String
    let instructions: String
}

let instructionTemplates = [
    InstructionTemplate(
        name: "Professional",
        icon: "briefcase.fill",
        description: "Formal and detailed",
        instructions: "Please provide professional, well-structured responses with clear explanations. Use formal language and be thorough in your answers."
    ),
    InstructionTemplate(
        name: "Concise",
        icon: "text.line.first.and.arrowtriangle.forward",
        description: "Brief and to the point",
        instructions: "Keep responses brief and to the point. Avoid unnecessary elaboration. Focus on key information only."
    ),
    InstructionTemplate(
        name: "Creative",
        icon: "paintbrush.fill",
        description: "Imaginative and engaging",
        instructions: "Be creative and imaginative in your responses. Use metaphors, analogies, and engaging language to make explanations more interesting."
    ),
    InstructionTemplate(
        name: "Teacher",
        icon: "graduationcap.fill",
        description: "Educational approach",
        instructions: "Explain concepts as if teaching. Break down complex ideas into simple parts. Provide examples and ensure understanding."
    ),
    InstructionTemplate(
        name: "Technical",
        icon: "chevron.left.forwardslash.chevron.right",
        description: "Detailed technical focus",
        instructions: "Provide detailed technical explanations with precision. Include code examples where relevant. Focus on accuracy and completeness."
    ),
    InstructionTemplate(
        name: "Friendly",
        icon: "face.smiling.fill",
        description: "Warm and conversational",
        instructions: "Be warm, friendly, and conversational. Use a casual tone while remaining helpful and informative."
    )
]

#Preview {
    NavigationStack {
        AssistantView()
    }
}