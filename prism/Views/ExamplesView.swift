//
//  ExamplesView.swift
//  Prism
//
//  Placeholder for Examples feature
//

import SwiftUI

struct ExamplesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Examples")
                    .font(.largeTitle)
                    .bold()

                Text("Coming soon: Structured generation examples")
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Examples")
    }
}

#Preview {
    NavigationStack {
        ExamplesView()
    }
}