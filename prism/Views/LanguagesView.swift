//
//  LanguagesView.swift
//  Prism
//
//  Placeholder for Languages feature
//

import SwiftUI

struct LanguagesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Languages")
                    .font(.largeTitle)
                    .bold()

                Text("Coming soon: Multi-language support")
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Languages")
    }
}

#Preview {
    NavigationStack {
        LanguagesView()
    }
}