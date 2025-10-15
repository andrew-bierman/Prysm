//
//  ContentView.swift
//  prism
//
//  Created by Andrew Bierman on 10/15/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var chatViewModel: ChatViewModel?
    @State private var showingSettings = false

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Settings") {
                        showingSettings = true
                    }
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            SimpleChatView(modelContext: modelContext)
        }
        #if os(iOS)
        .sheet(isPresented: $showingSettings) {
            if let viewModel = chatViewModel {
                SettingsView(viewModel: viewModel)
            }
        }
        #endif
        #if os(visionOS)
        .ornament(attachmentAnchor: .scene(.topTrailing)) {
            if showingSettings, let viewModel = chatViewModel {
                SettingsView(viewModel: viewModel)
                    .frame(width: 400, height: 600)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        #endif
        .onReceive(NotificationCenter.default.publisher(for: .settingsRequested)) { _ in
            showingSettings = true
        }
        .onAppear {
            if chatViewModel == nil {
                chatViewModel = ChatViewModel(modelContext: modelContext)
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
