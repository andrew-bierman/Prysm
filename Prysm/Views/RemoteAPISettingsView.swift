//
//  RemoteAPISettingsView.swift
//  Prysm
//

import SwiftUI

struct RemoteAPISettingsView: View {
    @Binding var viewModel: ChatViewModel
    @State private var baseURL: String = ""
    @State private var apiKey: String = ""
    @State private var modelName: String = ""
    @State private var isTestingConnection: Bool = false
    @State private var connectionStatus: ConnectionStatus?

    enum ConnectionStatus {
        case success(String)
        case failure(String)
    }

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("Endpoint URL")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("http://localhost:1234", text: $baseURL)
                        .textFieldStyle(.plain)
#if os(iOS)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
#endif
                }

                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("API Key (optional for local servers)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    SecureField("sk-...", text: $apiKey)
                        .textFieldStyle(.plain)
                }

                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("Model Name")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("default", text: $modelName)
                        .textFieldStyle(.plain)
#if os(iOS)
                        .autocapitalization(.none)
#endif
                }
            } header: {
                Text("Connection")
            } footer: {
                Text("Works with LM Studio, Ollama, OpenAI, and any OpenAI-compatible API.")
            }

            Section {
                Button {
                    testConnection()
                } label: {
                    HStack {
                        Label("Test Connection", systemImage: "antenna.radiowaves.left.and.right")
                        Spacer()
                        if isTestingConnection {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                .disabled(baseURL.isEmpty || isTestingConnection)

                if let status = connectionStatus {
                    switch status {
                    case .success(let msg):
                        Label(msg, systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    case .failure(let msg):
                        Label(msg, systemImage: "xmark.circle.fill")
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }

            Section {
                Button("Save Configuration") {
                    saveConfig()
                }
                .disabled(baseURL.isEmpty)
            }

            Section {
                VStack(alignment: .leading, spacing: Spacing.medium) {
                    Label("Quick Setup Guides", systemImage: "book")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("LM Studio")
                            .font(.subheadline)
                            .bold()
                        Text("1. Open LM Studio and load a model\n2. Start the local server (default: http://localhost:1234)\n3. Enter the URL above")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Ollama")
                            .font(.subheadline)
                            .bold()
                        Text("1. Run: ollama serve\n2. URL: http://localhost:11434\n3. Model name: the model you pulled (e.g., llama3)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Remote API")
#if os(iOS)
        .navigationBarTitleDisplayMode(.large)
#else
        .formStyle(.grouped)
#endif
        .onAppear {
            baseURL = viewModel.remoteProvider.config.baseURL
            apiKey = viewModel.remoteProvider.config.apiKey
            modelName = viewModel.remoteProvider.config.modelName
        }
    }

    private func saveConfig() {
        let config = RemoteProviderConfig(
            baseURL: baseURL,
            apiKey: apiKey,
            modelName: modelName.isEmpty ? "default" : modelName
        )
        viewModel.updateRemoteConfig(config)
    }

    private func testConnection() {
        isTestingConnection = true
        connectionStatus = nil
        saveConfig()

        Task {
            do {
                guard let url = URL(string: "\(baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/")))/v1/models") else {
                    await MainActor.run {
                        connectionStatus = .failure("Invalid URL")
                        isTestingConnection = false
                    }
                    return
                }

                var request = URLRequest(url: url)
                request.timeoutInterval = 10
                if !apiKey.isEmpty {
                    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                }

                let (data, response) = try await URLSession.shared.data(for: request)

                await MainActor.run {
                    if let httpResponse = response as? HTTPURLResponse,
                       (200...299).contains(httpResponse.statusCode) {
                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let models = json["data"] as? [[String: Any]] {
                            connectionStatus = .success("Connected! \(models.count) model(s) available.")
                        } else {
                            connectionStatus = .success("Connected successfully!")
                        }
                    } else {
                        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                        connectionStatus = .failure("HTTP \(statusCode)")
                    }
                    isTestingConnection = false
                }
            } catch {
                await MainActor.run {
                    connectionStatus = .failure(error.localizedDescription)
                    isTestingConnection = false
                }
            }
        }
    }
}
