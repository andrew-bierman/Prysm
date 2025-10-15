import SwiftUI
import UniformTypeIdentifiers
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Use Case Definition

enum AIUseCase: String, CaseIterable, Identifiable {
    case general = "general"
    case creative = "creative"
    case analytical = "analytical"
    case coding = "coding"
    case research = "research"
    case education = "education"
    case business = "business"
    case technical = "technical"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .general: return "General Assistant"
        case .creative: return "Creative Writing"
        case .analytical: return "Data Analysis"
        case .coding: return "Code Generation"
        case .research: return "Research Helper"
        case .education: return "Educational Tutor"
        case .business: return "Business Assistant"
        case .technical: return "Technical Documentation"
        }
    }

    var description: String {
        switch self {
        case .general: return "Balanced approach for everyday tasks"
        case .creative: return "Enhanced creativity and storytelling"
        case .analytical: return "Logical reasoning and data insights"
        case .coding: return "Programming assistance and debugging"
        case .research: return "Information gathering and synthesis"
        case .education: return "Teaching and learning support"
        case .business: return "Professional communication and strategy"
        case .technical: return "Technical writing and documentation"
        }
    }

    var recommendedSettings: ChatSettings {
        var settings = ChatSettings()

        switch self {
        case .general:
            settings.temperature = 0.7
            settings.topP = 0.9
            settings.systemPrompt = "You are Prism, a helpful AI assistant."
        case .creative:
            settings.temperature = 1.2
            settings.topP = 0.95
            settings.systemPrompt = "You are Prism, a creative AI assistant focused on imaginative and original content creation."
        case .analytical:
            settings.temperature = 0.3
            settings.topP = 0.8
            settings.systemPrompt = "You are Prism, an analytical AI assistant focused on logical reasoning and data-driven insights."
        case .coding:
            settings.temperature = 0.2
            settings.topP = 0.85
            settings.systemPrompt = "You are Prism, a programming AI assistant. Provide clear, efficient, and well-documented code solutions."
        case .research:
            settings.temperature = 0.5
            settings.topP = 0.9
            settings.systemPrompt = "You are Prism, a research AI assistant. Provide thorough, accurate, and well-sourced information."
        case .education:
            settings.temperature = 0.6
            settings.topP = 0.9
            settings.systemPrompt = "You are Prism, an educational AI assistant. Explain concepts clearly and encourage learning."
        case .business:
            settings.temperature = 0.4
            settings.topP = 0.85
            settings.systemPrompt = "You are Prism, a business AI assistant. Provide professional, strategic, and actionable advice."
        case .technical:
            settings.temperature = 0.3
            settings.topP = 0.8
            settings.systemPrompt = "You are Prism, a technical AI assistant. Provide precise, detailed, and accurate technical information."
        }

        return settings
    }
}

// MARK: - Platform Info

struct PlatformInfo {
    static var currentPlatform: String {
        #if os(iOS)
        return UIDevice.current.systemName
        #elseif os(macOS)
        return "macOS"
        #elseif os(visionOS)
        return "visionOS"
        #else
        return "Unknown"
        #endif
    }

    static var deviceModel: String {
        #if os(iOS)
        return UIDevice.current.model
        #elseif os(macOS)
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
        #elseif os(visionOS)
        return "Apple Vision Pro"
        #else
        return "Unknown Device"
        #endif
    }

    static var osVersion: String {
        #if os(iOS)
        return UIDevice.current.systemVersion
        #elseif os(macOS)
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        #elseif os(visionOS)
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        #else
        return "Unknown"
        #endif
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ChatViewModel
    @State private var showingClearConfirmation = false
    @State private var showingExportPicker = false
    @State private var showingImportPicker = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var exportedData: Data?
    @State private var selectedUseCase: AIUseCase
    @State private var tempSettings: ChatSettings
    @State private var hasUnsavedChanges = false

    // Form validation states
    @State private var temperatureText: String
    @State private var topPText: String
    @State private var maxTokensText: String
    @State private var systemPromptText: String

    @State private var temperatureError: String?
    @State private var topPError: String?
    @State private var maxTokensError: String?
    @State private var systemPromptError: String?

    init(viewModel: ChatViewModel) {
        self._viewModel = State(initialValue: viewModel)
        self._selectedUseCase = State(initialValue: AIUseCase(rawValue: viewModel.settings.useCase) ?? .general)
        self._tempSettings = State(initialValue: viewModel.settings)
        self._temperatureText = State(initialValue: String(format: "%.1f", viewModel.settings.temperature))
        self._topPText = State(initialValue: String(format: "%.2f", viewModel.settings.topP))
        self._maxTokensText = State(initialValue: String(viewModel.settings.maxTokens))
        self._systemPromptText = State(initialValue: viewModel.settings.systemPrompt)
    }

    var body: some View {
        NavigationStack {
            settingsContent
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarLeading) {
                        #if os(macOS)
                        EmptyView()
                        #else
                        Button("Cancel") {
                            if hasUnsavedChanges {
                                showResetConfirmation()
                            } else {
                                dismiss()
                            }
                        }
                        #endif
                    }

                    ToolbarItemGroup(placement: .topBarTrailing) {
                        if hasUnsavedChanges {
                            Button("Reset") {
                                showResetConfirmation()
                            }
                            .foregroundColor(.orange)
                        }

                        Button("Save") {
                            saveSettings()
                        }
                        .fontWeight(.semibold)
                        .disabled(!isFormValid || !hasUnsavedChanges)
                    }
                }
                #if os(macOS)
                .frame(minWidth: 600, minHeight: 700)
                #endif
        }
        .alert("Clear Session", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                Task {
                    await viewModel.clearSession()
                }
            }
        } message: {
            Text("This will permanently delete all messages in the current session. This action cannot be undone.")
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .fileExporter(
            isPresented: $showingExportPicker,
            document: ExportDocument(data: exportedData ?? Data()),
            contentType: .json,
            defaultFilename: "prism-settings-\(Date().formatted(.iso8601.year().month().day()))"
        ) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                showError("Export failed: \(error.localizedDescription)")
            }
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                importSettings(from: url)
            case .failure(let error):
                showError("Import failed: \(error.localizedDescription)")
            }
        }
        .onAppear {
            setupInitialValues()
        }
        #if os(macOS)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
            if hasUnsavedChanges {
                saveSettings()
            }
        }
        #endif
    }

    @ViewBuilder
    private var settingsContent: View {
        #if os(visionOS)
        visionOSContent
        #else
        Form {
            formSections
        }
        #if os(iOS)
        .background(Color(.systemGroupedBackground))
        #endif
        #endif
    }

    #if os(visionOS)
    private var visionOSContent: View {
        ScrollView {
            LazyVStack(spacing: 20) {
                formSections
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding()
    }
    #endif

    @ViewBuilder
    private var formSections: View {
        modelConfigurationSection
        systemPromptSection
        useCaseSection
        responseOptionsSection
        sessionManagementSection
        platformInfoSection
        exportImportSection
    }

    // MARK: - Form Sections

    private var modelConfigurationSection: View {
        Section {
            VStack(spacing: 16) {
                // Temperature Control
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Temperature", systemImage: "thermometer")
                        Spacer()
                        Text(String(format: "%.1f", tempSettings.temperature))
                            .foregroundColor(.secondary)
                            .monospacedDigit()
                    }

                    Slider(
                        value: $tempSettings.temperature,
                        in: 0.0...2.0,
                        step: 0.1
                    ) {
                        Text("Temperature")
                    } minimumValueLabel: {
                        Text("0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } maximumValueLabel: {
                        Text("2.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .onChange(of: tempSettings.temperature) { _, _ in
                        markAsChanged()
                    }

                    Text("Controls randomness. Lower values make responses more focused and deterministic.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Temperature: \(String(format: "%.1f", tempSettings.temperature))")
                .accessibilityHint("Controls response randomness from 0.0 to 2.0")

                Divider()

                // Top P Control
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Top P", systemImage: "arrow.up.circle")
                        Spacer()
                        Text(String(format: "%.2f", tempSettings.topP))
                            .foregroundColor(.secondary)
                            .monospacedDigit()
                    }

                    Slider(
                        value: $tempSettings.topP,
                        in: 0.0...1.0,
                        step: 0.05
                    ) {
                        Text("Top P")
                    } minimumValueLabel: {
                        Text("0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } maximumValueLabel: {
                        Text("1.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .onChange(of: tempSettings.topP) { _, _ in
                        markAsChanged()
                    }

                    Text("Controls diversity via nucleus sampling. Lower values focus on most likely tokens.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Top P: \(String(format: "%.2f", tempSettings.topP))")
                .accessibilityHint("Controls response diversity from 0.0 to 1.0")

                Divider()

                // Max Tokens Control
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Max Tokens", systemImage: "textformat.123")
                        Spacer()

                        TextField("Max Tokens", text: $maxTokensText)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .frame(width: 100)
                            .multilineTextAlignment(.trailing)
                            .onSubmit {
                                validateMaxTokens()
                            }
                            .onChange(of: maxTokensText) { _, newValue in
                                validateMaxTokens()
                                markAsChanged()
                            }
                    }

                    if let error = maxTokensError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    Text("Maximum number of tokens in the response (1-32768).")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Max Tokens")
                .accessibilityValue(maxTokensText)
                .accessibilityHint("Maximum response length in tokens")
            }
        } header: {
            Label("Model Configuration", systemImage: "cpu")
        }
    }

    private var systemPromptSection: View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                TextEditor(text: $systemPromptText)
                    .frame(minHeight: 120, maxHeight: 200)
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
                    .onChange(of: systemPromptText) { _, _ in
                        validateSystemPrompt()
                        markAsChanged()
                    }
                    .accessibilityLabel("System Prompt")
                    .accessibilityHint("Instructions that guide the AI's behavior and personality")

                if let error = systemPromptError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }

                HStack {
                    Text("\(systemPromptText.count) characters")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Button("Reset to Default") {
                        systemPromptText = "You are Prism, a helpful AI assistant."
                        validateSystemPrompt()
                        markAsChanged()
                    }
                    .font(.caption)
                    .buttonStyle(.borderless)
                }
            }
        } header: {
            Label("System Prompt", systemImage: "text.alignleft")
        } footer: {
            Text("Instructions that guide the AI's behavior and personality. This message is sent with every conversation.")
        }
    }

    private var useCaseSection: View {
        Section {
            Picker("Use Case", selection: $selectedUseCase) {
                ForEach(AIUseCase.allCases) { useCase in
                    VStack(alignment: .leading) {
                        Text(useCase.displayName)
                            .font(.headline)
                        Text(useCase.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .tag(useCase)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selectedUseCase) { _, newValue in
                applyUseCaseSettings(newValue)
                markAsChanged()
            }
            .accessibilityLabel("AI Use Case")
            .accessibilityValue(selectedUseCase.displayName)

            Button("Apply Recommended Settings") {
                applyUseCaseSettings(selectedUseCase)
                markAsChanged()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        } header: {
            Label("Use Case", systemImage: "target")
        } footer: {
            Text("Preset configurations optimized for different types of tasks. Applying recommended settings will override current model configuration.")
        }
    }

    private var responseOptionsSection: View {
        Section {
            Toggle("Stream Responses", isOn: $tempSettings.streamResponses)
                .onChange(of: tempSettings.streamResponses) { _, _ in
                    markAsChanged()
                }
                .accessibilityHint("Receive responses word by word as they're generated")

            Toggle("Enable Tools", isOn: $tempSettings.enableTools)
                .onChange(of: tempSettings.enableTools) { _, _ in
                    markAsChanged()
                }
                .accessibilityHint("Allow the AI to use external tools and functions")

            Toggle("Auto-save Conversations", isOn: $tempSettings.autoSave)
                .onChange(of: tempSettings.autoSave) { _, _ in
                    markAsChanged()
                }
                .accessibilityHint("Automatically save conversation history")
        } header: {
            Label("Response Options", systemImage: "slider.horizontal.3")
        }
    }

    private var sessionManagementSection: View {
        Section {
            Button("Clear Current Session") {
                showingClearConfirmation = true
            }
            .foregroundColor(.red)
            .accessibilityHint("Delete all messages in the current conversation")

            HStack {
                Label("Message Count", systemImage: "message")
                Spacer()
                Text("\(viewModel.messages.count)")
                    .foregroundColor(.secondary)
            }

            HStack {
                Label("Token Usage", systemImage: "textformat.123")
                Spacer()
                Text("\(viewModel.tokenUsage)")
                    .foregroundColor(.secondary)
            }

            if viewModel.responseTime > 0 {
                HStack {
                    Label("Last Response Time", systemImage: "clock")
                    Spacer()
                    Text(String(format: "%.2fs", viewModel.responseTime))
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                }
            }
        } header: {
            Label("Session Management", systemImage: "doc.text")
        }
    }

    private var platformInfoSection: View {
        Section {
            HStack {
                Label("Platform", systemImage: "display")
                Spacer()
                Text(PlatformInfo.currentPlatform)
                    .foregroundColor(.secondary)
            }

            HStack {
                Label("Device", systemImage: "iphone")
                Spacer()
                Text(PlatformInfo.deviceModel)
                    .foregroundColor(.secondary)
            }

            HStack {
                Label("OS Version", systemImage: "gear")
                Spacer()
                Text(PlatformInfo.osVersion)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }

            HStack {
                Label("App Version", systemImage: "app.badge")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                    .foregroundColor(.secondary)
            }
        } header: {
            Label("Platform Information", systemImage: "info.circle")
        }
    }

    private var exportImportSection: View {
        Section {
            Button("Export Settings") {
                exportSettings()
            }
            .accessibilityHint("Save current settings to a file")

            Button("Import Settings") {
                showingImportPicker = true
            }
            .accessibilityHint("Load settings from a file")

            Button("Export Conversation") {
                exportConversation()
            }
            .disabled(viewModel.messages.isEmpty)
            .accessibilityHint("Save current conversation to a file")
        } header: {
            Label("Export & Import", systemImage: "square.and.arrow.up")
        } footer: {
            Text("Export your settings and conversations to share across devices or create backups.")
        }
    }

    // MARK: - Validation Methods

    private var isFormValid: Bool {
        temperatureError == nil &&
        topPError == nil &&
        maxTokensError == nil &&
        systemPromptError == nil
    }

    private func validateMaxTokens() {
        guard let tokens = Int(maxTokensText) else {
            maxTokensError = "Must be a valid number"
            return
        }

        if tokens < 1 {
            maxTokensError = "Must be at least 1"
        } else if tokens > 32768 {
            maxTokensError = "Must be 32768 or less"
        } else {
            maxTokensError = nil
            tempSettings.maxTokens = tokens
        }
    }

    private func validateSystemPrompt() {
        let trimmed = systemPromptText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            systemPromptError = "System prompt cannot be empty"
        } else if trimmed.count > 10000 {
            systemPromptError = "System prompt is too long (max 10,000 characters)"
        } else {
            systemPromptError = nil
            tempSettings.systemPrompt = systemPromptText
        }
    }

    // MARK: - Helper Methods

    private func setupInitialValues() {
        validateMaxTokens()
        validateSystemPrompt()
    }

    private func markAsChanged() {
        hasUnsavedChanges = true
    }

    private func applyUseCaseSettings(_ useCase: AIUseCase) {
        let recommendedSettings = useCase.recommendedSettings

        tempSettings.temperature = recommendedSettings.temperature
        tempSettings.topP = recommendedSettings.topP
        systemPromptText = recommendedSettings.systemPrompt
        tempSettings.useCase = useCase.rawValue

        validateSystemPrompt()
    }

    private func saveSettings() {
        guard isFormValid else {
            showError("Please fix the validation errors before saving.")
            return
        }

        tempSettings.useCase = selectedUseCase.rawValue
        viewModel.updateSettings(tempSettings)
        hasUnsavedChanges = false

        #if os(macOS)
        // On macOS, settings window stays open
        #else
        dismiss()
        #endif
    }

    private func showResetConfirmation() {
        // Reset to original settings
        tempSettings = viewModel.settings
        selectedUseCase = AIUseCase(rawValue: viewModel.settings.useCase) ?? .general
        temperatureText = String(format: "%.1f", viewModel.settings.temperature)
        topPText = String(format: "%.2f", viewModel.settings.topP)
        maxTokensText = String(viewModel.settings.maxTokens)
        systemPromptText = viewModel.settings.systemPrompt
        hasUnsavedChanges = false

        // Clear validation errors
        temperatureError = nil
        topPError = nil
        maxTokensError = nil
        systemPromptError = nil

        #if !os(macOS)
        dismiss()
        #endif
    }

    private func exportSettings() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            exportedData = try encoder.encode(tempSettings)
            showingExportPicker = true
        } catch {
            showError("Failed to export settings: \(error.localizedDescription)")
        }
    }

    private func importSettings(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let importedSettings = try decoder.decode(ChatSettings.self, from: data)

            if importedSettings.isValid {
                tempSettings = importedSettings
                selectedUseCase = AIUseCase(rawValue: importedSettings.useCase) ?? .general
                temperatureText = String(format: "%.1f", importedSettings.temperature)
                topPText = String(format: "%.2f", importedSettings.topP)
                maxTokensText = String(importedSettings.maxTokens)
                systemPromptText = importedSettings.systemPrompt
                markAsChanged()
            } else {
                showError("The imported settings file contains invalid values.")
            }
        } catch {
            showError("Failed to import settings: \(error.localizedDescription)")
        }
    }

    private func exportConversation() {
        Task {
            do {
                let data = try await viewModel.exportConversation(format: .json)
                await MainActor.run {
                    exportedData = data
                    showingExportPicker = true
                }
            } catch {
                await MainActor.run {
                    showError("Failed to export conversation: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}

// MARK: - Export Document

struct ExportDocument: FileDocument {
    static let readableContentTypes = [UTType.json]

    let data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}

// MARK: - Keyboard Shortcuts Extension

#if os(macOS)
extension SettingsView {
    private var keyboardShortcuts: some View {
        EmptyView()
            .onReceive(NotificationCenter.default.publisher(for: .settingsKeyboardShortcut)) { _ in
                // Handle Cmd+, shortcut
            }
    }
}

extension Notification.Name {
    static let settingsKeyboardShortcut = Notification.Name("settingsKeyboardShortcut")
}
#endif

// MARK: - Preview

#Preview("iOS Settings") {
    NavigationStack {
        SettingsView(viewModel: ChatViewModel())
    }
}

#Preview("macOS Settings") {
    SettingsView(viewModel: ChatViewModel())
        .frame(width: 600, height: 700)
}