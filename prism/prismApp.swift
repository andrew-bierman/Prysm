//
//  PrismApp.swift
//  Prism
//
//  Created by Andrew Bierman on 10/15/25.
//

import SwiftUI
import SwiftData
import CloudKit

@main
struct PrismApp: App {

    // MARK: - State Management
    @AppStorage("accentColor") private var selectedAccentColor: String = "blue"
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    @State private var showingSettings: Bool = false

    // MARK: - SwiftData Model Container
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            Message.self,
        ])

        // Configure CloudKit container for sync
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.com.andrewbierman.prism")
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Enable CloudKit remote change notifications
            if let cloudKitContainer = container.configurations.first?.cloudKitDatabase {
                try? cloudKitContainer.record(for: modelConfiguration)
            }

            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Scene Configuration
    var body: some Scene {
        WindowGroup("Prism") {
            ContentView()
                .environmentObject(AppState.shared)
                .environment(\.colorScheme, .automatic)
                .onAppear {
                    setupAppearance()
                    if !hasLaunchedBefore {
                        hasLaunchedBefore = true
                    }
                }
        }
        .modelContainer(sharedModelContainer)
        .commands {
            // File Menu Commands
            CommandGroup(replacing: .newItem) {
                Button("New Chat") {
                    NotificationCenter.default.post(name: .newChatRequested, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }

            // Edit Menu Commands
            CommandGroup(after: .textEditing) {
                Divider()
                Button("Reset Chat") {
                    NotificationCenter.default.post(name: .resetChatRequested, object: nil)
                }
                .keyboardShortcut("r", modifiers: .command)

                Button("Clear All Messages") {
                    NotificationCenter.default.post(name: .clearAllMessagesRequested, object: nil)
                }
                .keyboardShortcut("k", modifiers: [.command, .shift])
            }

            // View Menu Commands
            CommandGroup(after: .toolbar) {
                Divider()
                Button("Toggle Sidebar") {
                    NotificationCenter.default.post(name: .toggleSidebarRequested, object: nil)
                }
                .keyboardShortcut("s", modifiers: [.command, .option])

                Button("Focus Message Input") {
                    NotificationCenter.default.post(name: .focusMessageInputRequested, object: nil)
                }
                .keyboardShortcut("/", modifiers: .command)
            }

            // Settings Menu
            CommandGroup(replacing: .appSettings) {
                Button("Prism Settings...") {
                    showingSettings = true
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
        .defaultSize(width: 1200, height: 800)
        #if os(macOS)
        .windowResizability(.contentSize)
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        #endif

        #if os(macOS)
        // Settings Window for macOS
        Settings {
            SettingsView(viewModel: ChatViewModel())
                .environmentObject(AppState.shared)
        }
        #endif

        #if os(visionOS)
        // visionOS specific window configuration
        WindowGroup("Prism Chat", id: "prism-chat") {
            ContentView()
                .environmentObject(AppState.shared)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 800, height: 600, depth: 400, in: .points)
        .windowResizability(.contentSize)
        .ornament(attachmentAnchor: .scene(.bottom)) {
            VisionOSControlsView()
                .environmentObject(AppState.shared)
        }

        ImmersiveSpace("Immersive Prism", id: "immersive-prism") {
            ImmersivePrismView()
                .environmentObject(AppState.shared)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        #endif
    }

    // MARK: - App Lifecycle
    init() {
        setupAppearance()
        configureCloudKit()
    }

    // MARK: - Private Methods
    private func setupAppearance() {
        // Set accent color based on user preference
        let accentColor = AppAccentColor.allCases.first { $0.rawValue == selectedAccentColor } ?? .blue

        #if os(macOS)
        NSApp.appearance = NSAppearance(named: .aqua)
        #endif

        // Configure navigation and tab bar appearance
        #if os(iOS)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        #endif
    }

    private func configureCloudKit() {
        // Configure CloudKit container for remote notifications
        #if !targetEnvironment(simulator)
        Task {
            do {
                let container = CKContainer(identifier: "iCloud.com.andrewbierman.prism")
                try await container.accountStatus()
            } catch {
                print("CloudKit configuration error: \(error)")
            }
        }
        #endif
    }
}

// MARK: - App State Management
class AppState: ObservableObject {
    static let shared = AppState()

    @Published var selectedConversation: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var networkStatus: NetworkStatus = .connected

    private init() {}
}

// MARK: - Supporting Types
enum NetworkStatus {
    case connected
    case disconnected
    case connecting
}

enum AppAccentColor: String, CaseIterable {
    case blue = "blue"
    case purple = "purple"
    case pink = "pink"
    case red = "red"
    case orange = "orange"
    case yellow = "yellow"
    case green = "green"
    case mint = "mint"
    case teal = "teal"
    case cyan = "cyan"
    case indigo = "indigo"

    var color: Color {
        switch self {
        case .blue: return .blue
        case .purple: return .purple
        case .pink: return .pink
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .mint: return .mint
        case .teal: return .teal
        case .cyan: return .cyan
        case .indigo: return .indigo
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let newChatRequested = Notification.Name("newChatRequested")
    static let resetChatRequested = Notification.Name("resetChatRequested")
    static let clearAllMessagesRequested = Notification.Name("clearAllMessagesRequested")
    static let toggleSidebarRequested = Notification.Name("toggleSidebarRequested")
    static let focusMessageInputRequested = Notification.Name("focusMessageInputRequested")
    static let settingsRequested = Notification.Name("settingsRequested")
}

// MARK: - Legacy Settings Views (for reference)
struct LegacyGeneralSettingsView: View {
    @Binding var selectedAccentColor: String
    @Binding var enableCloudSync: Bool
    @Binding var enableNotifications: Bool

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Accent Color", selection: $selectedAccentColor) {
                    ForEach(AppAccentColor.allCases, id: \.rawValue) { color in
                        Label(color.rawValue.capitalized, systemImage: "circle.fill")
                            .foregroundColor(color.color)
                            .tag(color.rawValue)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("Sync & Storage") {
                Toggle("Enable iCloud Sync", isOn: $enableCloudSync)
                Text("Sync your conversations across all your devices using iCloud.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section("Notifications") {
                Toggle("Enable Notifications", isOn: $enableNotifications)
                Text("Receive notifications for important updates and responses.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct LegacyAdvancedSettingsView: View {
    @AppStorage("enableDebugMode") private var enableDebugMode: Bool = false
    @AppStorage("maxTokensPerRequest") private var maxTokensPerRequest: Double = 4000

    var body: some View {
        Form {
            Section("Developer") {
                Toggle("Debug Mode", isOn: $enableDebugMode)
                Text("Enable debug logging and additional developer features.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section("AI Configuration") {
                VStack(alignment: .leading) {
                    Text("Max Tokens per Request: \(Int(maxTokensPerRequest))")
                    Slider(value: $maxTokensPerRequest, in: 1000...8000, step: 500)
                }
                Text("Adjust the maximum number of tokens per AI request.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - visionOS Specific Views
#if os(visionOS)
struct VisionOSControlsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        HStack(spacing: 20) {
            Button("New Chat") {
                NotificationCenter.default.post(name: .newChatRequested, object: nil)
            }
            .buttonStyle(.borderedProminent)

            Button("Reset") {
                NotificationCenter.default.post(name: .resetChatRequested, object: nil)
            }
            .buttonStyle(.bordered)

            Button("Settings") {
                NotificationCenter.default.post(name: .settingsRequested, object: nil)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct ImmersivePrismView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack {
            Text("Immersive Prism Experience")
                .font(.largeTitle)
                .padding()

            Text("Welcome to the immersive AI chat experience")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
#endif