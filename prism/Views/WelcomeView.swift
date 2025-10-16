//
//  WelcomeView.swift
//  Prism
//
//  Based on Foundation-Models-Framework-Example
//

import SwiftUI

struct WelcomeView: View {
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                WelcomePageView(
                    title: "Welcome to Prism",
                    subtitle: "Your AI companion powered by Apple Intelligence",
                    systemImage: "sparkles",
                    description: "Experience the power of on-device AI with privacy and performance at its core.",
                    gradient: [.blue, .purple]
                )
                .tag(0)

                WelcomePageView(
                    title: "Smart Conversations",
                    subtitle: "Chat naturally with advanced AI",
                    systemImage: "bubble.left.and.bubble.right",
                    description: "Have meaningful conversations, ask questions, and get intelligent responses instantly.",
                    gradient: [.purple, .pink]
                )
                .tag(1)

                WelcomePageView(
                    title: "Creative Tools",
                    subtitle: "Generate content with structure",
                    systemImage: "wand.and.stars",
                    description: "Create recipes, stories, emails, and more with our specialized generation tools.",
                    gradient: [.pink, .orange]
                )
                .tag(2)

                WelcomePageView(
                    title: "Privacy First",
                    subtitle: "Your data stays on your device",
                    systemImage: "lock.shield",
                    description: "All processing happens locally. Your conversations never leave your device.",
                    gradient: [.green, .blue]
                )
                .tag(3)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            VStack(spacing: Spacing.medium) {
                if currentPage < 3 {
                    Button {
                        withAnimation {
                            currentPage += 1
                        }
                    } label: {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                } else {
                    Button {
                        hasSeenWelcome = true
                        isPresented = false
                    } label: {
                        Text("Get Started")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }

                Button {
                    hasSeenWelcome = true
                    isPresented = false
                } label: {
                    Text(currentPage < 3 ? "Skip" : "")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}

struct WelcomePageView: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let description: String
    let gradient: [Color]

    @State private var animate = false

    var body: some View {
        VStack(spacing: Spacing.xLarge) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient.map { $0.opacity(0.3) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 20)
                    .scaleEffect(animate ? 1.1 : 0.9)

                Image(systemName: systemImage)
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(animate ? 1.0 : 0.95)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }

            VStack(spacing: Spacing.medium) {
                Text(title)
                    .font(.largeTitle)
                    .bold()

                Text(subtitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Text(description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }

            Spacer()
            Spacer()
        }
        .padding()
    }
}

#Preview {
    WelcomeView(isPresented: .constant(true))
}