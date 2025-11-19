//
//  SettingsView.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import SwiftUI
import FoundationModels

struct SettingsView: View {
    @AppStorage("autoSaveConversations") private var autoSaveConversations = true
    @AppStorage("enableHaptics") private var enableHaptics = true
    @AppStorage("showWordCount") private var showWordCount = false
    @AppStorage("appearanceMode") private var appearanceMode = "system"
    @AppStorage("accentColor") private var accentColorName = "blue"
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("enableSoundEffects") private var enableSoundEffects = true
    @AppStorage("fontSize") private var fontSize = "medium"
    @AppStorage("useBaseInstructions") private var useBaseInstructions = true
    @State private var showingResetAlert = false
    @State private var showingAbout = false

    var body: some View {
        Form {
            appearanceSection
            chatSection
            privacySection
            accessibilitySection
            notificationsSection
            dataSection
            aboutSection
        }
        .navigationTitle("Settings")
#if os(iOS)
        .navigationBarTitleDisplayMode(.large)
#else
        .formStyle(.grouped)
#endif
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .alert("Reset All Settings?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllSettings()
            }
        } message: {
            Text("This will reset all settings to their default values. This action cannot be undone.")
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Theme", selection: $appearanceMode) {
                Label("System", systemImage: "circle.lefthalf.filled").tag("system")
                Label("Light", systemImage: "sun.max.fill").tag("light")
                Label("Dark", systemImage: "moon.fill").tag("dark")
            }

            Picker("Accent Color", selection: $accentColorName) {
                HStack {
                    Circle().fill(.blue).frame(width: 12, height: 12)
                    Text("Blue")
                }.tag("blue")
                HStack {
                    Circle().fill(.purple).frame(width: 12, height: 12)
                    Text("Purple")
                }.tag("purple")
                HStack {
                    Circle().fill(.pink).frame(width: 12, height: 12)
                    Text("Pink")
                }.tag("pink")
                HStack {
                    Circle().fill(.green).frame(width: 12, height: 12)
                    Text("Green")
                }.tag("green")
                HStack {
                    Circle().fill(.orange).frame(width: 12, height: 12)
                    Text("Orange")
                }.tag("orange")
            }

            Picker("Font Size", selection: $fontSize) {
                Text("Small").tag("small")
                Text("Medium").tag("medium")
                Text("Large").tag("large")
                Text("Extra Large").tag("xlarge")
            }
        }
    }

    private var chatSection: some View {
        Section {
            Toggle("Use Base System Instructions", isOn: $useBaseInstructions)
            Toggle("Auto-save Conversations", isOn: $autoSaveConversations)
            Toggle("Show Word Count", isOn: $showWordCount)
            Toggle("Enable Haptic Feedback", isOn: $enableHaptics)
            Toggle("Sound Effects", isOn: $enableSoundEffects)

            NavigationLink(destination: GenerationOptionsView()) {
                Label("Generation Options", systemImage: "slider.horizontal.3")
            }
        } header: {
            Text("Chat")
        } footer: {
            if !useBaseInstructions {
                Text("Base system instructions are disabled. The AI will have no predefined behavior constraints.")
            }
        }
    }

    private var privacySection: some View {
        Section("Privacy & Security") {
            HStack {
                Image(systemName: "lock.shield.fill")
                    .foregroundStyle(.green)
                VStack(alignment: .leading) {
                    Text("On-Device Processing")
                        .font(.subheadline)
                    Text("Your data stays on your device")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Button {
                clearConversationHistory()
            } label: {
                Label("Clear Conversation History", systemImage: "trash")
                    .foregroundStyle(.red)
            }
        }
    }

    private var accessibilitySection: some View {
        Section("Accessibility") {
            Toggle("Reduce Motion", isOn: .constant(false))
            Toggle("Increase Contrast", isOn: .constant(false))
            Toggle("Voice Over Hints", isOn: .constant(true))
        }
    }

    private var notificationsSection: some View {
        Section("Notifications") {
            Toggle("Enable Notifications", isOn: $enableNotifications)

            if enableNotifications {
                Toggle("Daily Tips", isOn: .constant(true))
                Toggle("Feature Updates", isOn: .constant(true))
                Toggle("Community Highlights", isOn: .constant(false))
            }
        }
    }

    private var dataSection: some View {
        Section("Data & Storage") {
            HStack {
                Text("Cache Size")
                Spacer()
                Text("124 MB")
                    .foregroundStyle(.secondary)
            }

            Button("Clear Cache") {
                clearCache()
            }

            HStack {
                Text("Export Data")
                Spacer()
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(.secondary)
            }

            Button("Reset All Settings") {
                showingResetAlert = true
            }
            .foregroundStyle(.red)
        }
    }

    private var aboutSection: some View {
        Section {
            Button {
                showingAbout = true
            } label: {
                HStack {
                    Label("About \(AppConfig.appName)", systemImage: "info.circle")
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let privacyURL = AppConfig.privacyURL {
                Link(destination: privacyURL) {
                    HStack {
                        Label("Privacy Policy", systemImage: "hand.raised")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.forward.square")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if let termsURL = AppConfig.termsURL {
                Link(destination: termsURL) {
                    HStack {
                        Label("Terms of Service", systemImage: "doc.text")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.forward.square")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func resetAllSettings() {
        autoSaveConversations = true
        enableHaptics = true
        showWordCount = false
        appearanceMode = "system"
        accentColorName = "blue"
        enableNotifications = true
        enableSoundEffects = true
        fontSize = "medium"
        useBaseInstructions = true
    }

    private func clearConversationHistory() {
        // Clear UserDefaults for conversation-related data
        UserDefaults.standard.removeObject(forKey: "conversationHistory")
        UserDefaults.standard.removeObject(forKey: "savedTranscripts")

        // Clear any stored conversation summaries
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let conversationsURL = documentsDirectory.appendingPathComponent("Conversations")
            try? FileManager.default.removeItem(at: conversationsURL)
        }
    }

    private func clearCache() {
        // Clear URLCache
        URLCache.shared.removeAllCachedResponses()

        // Clear temporary directory
        let tempDirectory = FileManager.default.temporaryDirectory
        if let tempContents = try? FileManager.default.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil) {
            for file in tempContents {
                try? FileManager.default.removeItem(at: file)
            }
        }

        // Clear image cache if any
        URLCache.shared.diskCapacity = 0
        URLCache.shared.diskCapacity = 50 * 1024 * 1024 // Reset to 50MB
        URLCache.shared.memoryCapacity = 0
        URLCache.shared.memoryCapacity = 10 * 1024 * 1024 // Reset to 10MB
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var animateGradient = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    // App Icon and Name
                    VStack(spacing: Spacing.medium) {
                        ZStack {
                            LinearGradient(
                                colors: [.blue, .purple, .pink],
                                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                                endPoint: animateGradient ? .bottomTrailing : .topLeading
                            )
                            .mask(
                                Image(systemName: "sparkles")
                                    .font(.system(size: 80))
                            )
                            .frame(width: 100, height: 100)
                        }
                        .onAppear {
                            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                                animateGradient.toggle()
                            }
                        }

                        Text(AppConfig.appName)
                            .font(.largeTitle)
                            .bold()

                        Text(AppConfig.fullVersionString)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top)

                    // Description
                    VStack(spacing: Spacing.medium) {
                        Text("Powered by Apple Intelligence")
                            .font(.headline)

                        Text("\(AppConfig.appName) brings the power of advanced language models to your fingertips, with a focus on privacy, performance, and ease of use.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)

                    // Features
                    VStack(alignment: .leading, spacing: Spacing.medium) {
                        Text("Key Features")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(features, id: \.title) { feature in
                            HStack(alignment: .top, spacing: Spacing.medium) {
                                Image(systemName: feature.icon)
                                    .foregroundStyle(.blue)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: Spacing.xSmall) {
                                    Text(feature.title)
                                        .font(.subheadline)
                                        .bold()
                                    Text(feature.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)

                    // Credits
                    VStack(spacing: Spacing.small) {
                        Text("Built with SwiftUI and FoundationModels")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("© 2024 Luma AI. All rights reserved.")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .padding()
                }
            }
            .navigationTitle("About")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var features: [(title: String, description: String, icon: String)] {
        [
            ("On-Device Processing", "Your conversations stay private with local AI processing", "lock.shield"),
            ("Smart Examples", "Get inspired with curated prompts and templates", "lightbulb"),
            ("Structured Generation", "Create recipes, stories, and more with intelligent formatting", "doc.richtext"),
            ("Adaptive Interface", "Optimized for iPhone, iPad, and Mac", "devices.2"),
            ("Powerful Tools", "Extend capabilities with built-in productivity tools", "wrench.and.screwdriver"),
            ("Customizable", "Tailor the experience to your preferences", "slider.horizontal.3")
        ]
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}