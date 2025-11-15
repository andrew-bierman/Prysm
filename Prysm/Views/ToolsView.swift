//
//  ToolsView.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import SwiftUI

struct ToolsView: View {
    @State private var selectedCategory: ToolCategory = .productivity
    @State private var enabledTools: Set<String> = ["summarizer", "translator", "codeFormatter"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.large) {
                headerView

                categoryPicker

                toolsList
            }
            .padding()
        }
        .navigationTitle("Tools & Integrations")
#if os(iOS)
        .navigationBarTitleDisplayMode(.large)
#endif
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("Enhance Your Experience")
                .font(.title2)
                .bold()

            Text("Enable tools and integrations to extend \(AppConfig.appName)'s capabilities")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.medium) {
                ForEach(ToolCategory.allCases) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = category
                        }
                    }
                }
            }
        }
    }

    private var toolsList: some View {
        VStack(spacing: Spacing.medium) {
            ForEach(filteredTools) { tool in
                ToolCard(
                    tool: tool,
                    isEnabled: enabledTools.contains(tool.id)
                ) {
                    toggleTool(tool)
                }
            }
        }
    }

    private var filteredTools: [ToolItem] {
        ToolItem.allTools.filter { $0.category == selectedCategory }
    }

    private func toggleTool(_ tool: ToolItem) {
        withAnimation(.spring(response: 0.3)) {
            if enabledTools.contains(tool.id) {
                enabledTools.remove(tool.id)
            } else {
                enabledTools.insert(tool.id)
            }
        }
    }
}

enum ToolCategory: String, CaseIterable, Identifiable {
    case productivity = "Productivity"
    case creativity = "Creativity"
    case research = "Research"
    case development = "Development"
    case communication = "Communication"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .productivity: return "bolt.fill"
        case .creativity: return "paintbrush.fill"
        case .research: return "magnifyingglass"
        case .development: return "chevron.left.forwardslash.chevron.right"
        case .communication: return "bubble.left.and.bubble.right.fill"
        }
    }

    var color: Color {
        switch self {
        case .productivity: return .orange
        case .creativity: return .pink
        case .research: return .blue
        case .development: return .green
        case .communication: return .purple
        }
    }
}

struct ToolItem: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: ToolCategory
    let isPremium: Bool

    static let allTools = [
        // Productivity
        ToolItem(
            id: "summarizer",
            name: "Smart Summarizer",
            description: "Automatically summarize long texts and documents",
            icon: "doc.text.magnifyingglass",
            category: .productivity,
            isPremium: false
        ),
        ToolItem(
            id: "taskManager",
            name: "Task Manager",
            description: "Create and manage to-do lists and reminders",
            icon: "checklist",
            category: .productivity,
            isPremium: false
        ),
        ToolItem(
            id: "noteOrganizer",
            name: "Note Organizer",
            description: "Organize and categorize your notes automatically",
            icon: "folder.fill",
            category: .productivity,
            isPremium: false
        ),
        ToolItem(
            id: "webSearch",
            name: "Web Search",
            description: "Search the web for real-time information",
            icon: "globe.badge.chevron.backward",
            category: .productivity,
            isPremium: true
        ),

        // Creativity
        ToolItem(
            id: "imageGenerator",
            name: "Image Ideas",
            description: "Generate creative image descriptions and concepts",
            icon: "photo.fill",
            category: .creativity,
            isPremium: false
        ),
        ToolItem(
            id: "imageCreator",
            name: "AI Image Generation",
            description: "Create actual images from text descriptions (requires cloud)",
            icon: "photo.badge.plus.fill",
            category: .creativity,
            isPremium: true
        ),
        ToolItem(
            id: "storyBuilder",
            name: "Story Builder",
            description: "Build complex narratives with character tracking",
            icon: "book.fill",
            category: .creativity,
            isPremium: false
        ),
        ToolItem(
            id: "musicComposer",
            name: "Lyric Writer",
            description: "Generate song lyrics and poetry",
            icon: "music.note",
            category: .creativity,
            isPremium: false
        ),

        // Research
        ToolItem(
            id: "webResearch",
            name: "Live Web Research",
            description: "Access current information from the internet",
            icon: "magnifyingglass.circle.fill",
            category: .research,
            isPremium: true
        ),
        ToolItem(
            id: "factChecker",
            name: "Fact Checker",
            description: "Verify information and check sources",
            icon: "checkmark.shield.fill",
            category: .research,
            isPremium: false
        ),
        ToolItem(
            id: "citationHelper",
            name: "Citation Helper",
            description: "Format citations in various academic styles",
            icon: "quote.opening",
            category: .research,
            isPremium: false
        ),
        ToolItem(
            id: "dataAnalyzer",
            name: "Data Analyzer",
            description: "Analyze and visualize data patterns",
            icon: "chart.bar.fill",
            category: .research,
            isPremium: false
        ),

        // Development
        ToolItem(
            id: "githubIntegration",
            name: "GitHub Integration",
            description: "Connect to GitHub for code management",
            icon: "cloud.fill",
            category: .development,
            isPremium: true
        ),
        ToolItem(
            id: "codeFormatter",
            name: "Code Formatter",
            description: "Format and beautify code in multiple languages",
            icon: "curlybraces",
            category: .development,
            isPremium: false
        ),
        ToolItem(
            id: "debugHelper",
            name: "Debug Assistant",
            description: "Help identify and fix code issues",
            icon: "ant.fill",
            category: .development,
            isPremium: false
        ),
        ToolItem(
            id: "apiTester",
            name: "API Helper",
            description: "Test and document API endpoints",
            icon: "network",
            category: .development,
            isPremium: false
        ),

        // Communication
        ToolItem(
            id: "translator",
            name: "Language Translator",
            description: "Translate between multiple languages",
            icon: "globe",
            category: .communication,
            isPremium: false
        ),
        ToolItem(
            id: "voiceTranscription",
            name: "Voice Transcription Pro",
            description: "Advanced voice-to-text with cloud accuracy",
            icon: "mic.badge.plus",
            category: .communication,
            isPremium: true
        ),
        ToolItem(
            id: "toneAdjuster",
            name: "Tone Adjuster",
            description: "Adjust message tone for different audiences",
            icon: "slider.horizontal.3",
            category: .communication,
            isPremium: false
        ),
        ToolItem(
            id: "speechWriter",
            name: "Speech Writer",
            description: "Create compelling speeches and presentations",
            icon: "mic.fill",
            category: .communication,
            isPremium: false
        )
    ]
}

struct CategoryChip: View {
    let category: ToolCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xSmall) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.subheadline)
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small)
            .background(isSelected ? category.color : Color.gray.opacity(0.15))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct ToolCard: View {
    let tool: ToolItem
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.medium) {
                Image(systemName: tool.icon)
                    .font(.title2)
                    .foregroundStyle(tool.category.color)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: Spacing.xSmall) {
                    HStack {
                        Text(tool.name)
                            .font(.headline)

                        if tool.isPremium {
                            Label("Pro", systemImage: "star.fill")
                                .font(.caption2)
                                .padding(.horizontal, Spacing.small - 2)
                                .padding(.vertical, Spacing.xSmall / 2)
                                .background(Color.yellow.opacity(0.2))
                                .foregroundStyle(.orange)
                                .clipShape(Capsule())
                        }
                    }

                    Text(tool.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                Toggle("", isOn: .constant(isEnabled))
                    .labelsHidden()
                    .allowsHitTesting(false)
            }
            .padding()
            .background(isEnabled ? tool.category.color.opacity(0.1) : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(isEnabled ? tool.category.color : Color.secondary.opacity(0.2), lineWidth: isEnabled ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ToolsView()
    }
}