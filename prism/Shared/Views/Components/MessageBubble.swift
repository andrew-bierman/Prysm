//
//  MessageBubble.swift
//  Prism
//
//  Created by Claude Code on 10/15/25.
//

import SwiftUI
import AVFoundation

struct MessageBubble: View {
    let message: Message
    let viewModel: ChatViewModel

    @State private var isSelected = false
    @State private var showingShareSheet = false
    @State private var synthesizer = AVSpeechSynthesizer()

    @Environment(\.colorScheme) private var colorScheme

    init(message: Message, viewModel: ChatViewModel) {
        self.message = message
        self.viewModel = viewModel
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.role != .user {
                roleIcon
            }

            Spacer().frame(maxWidth: message.role == .user ? 60 : 0)

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                messageContent
                messageMetadata
            }

            Spacer().frame(maxWidth: message.role != .user ? 60 : 0)

            if message.role == .user {
                roleIcon
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isResponding)
    }

    private var roleIcon: some View {
        Image(systemName: message.role.iconName)
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(iconColor)
            .frame(width: 32, height: 32)
            .background(iconBackgroundColor)
            .clipShape(Circle())
            .accessibilityLabel(message.role.displayName)
    }

    private var messageContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let error = viewModel.currentError, message.role == .assistant {
                errorContent
            } else if viewModel.isResponding && message.role == .assistant && message.content.isEmpty {
                typingIndicator
            } else {
                textContent
            }
        }
        .padding(platformPadding)
        .background(bubbleBackground)
        .clipShape(bubbleShape)
        .overlay(
            bubbleShape
                .stroke(bubbleBorderColor, lineWidth: bubbleBorderWidth)
        )
        .contextMenu {
            contextMenuItems
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isSelected.toggle()
            }
        }
    }

    private var textContent: some View {
        Text(parseMarkdown(message.content))
            .font(.system(size: 15, weight: .regular, design: .default))
            .foregroundStyle(textColor)
            .textSelection(.enabled)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
            .accessibilityLabel("Message from \(message.role.displayName): \(message.content)")
    }

    private var typingIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(textColor.opacity(0.6))
                    .frame(width: 6, height: 6)
                    .scaleEffect(isTyping ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: isTyping
                    )
            }
        }
        .padding(.vertical, 8)
        .accessibilityLabel("Assistant is typing")
    }

    private var errorContent: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
                .font(.system(size: 14))

            Text("Failed to send message")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.red)
        }
        .accessibilityLabel("Message failed to send")
    }

    private var messageMetadata: some View {
        HStack(spacing: 8) {
            Text(relativeTimestamp(message.timestamp))
                .font(.caption2)
                .foregroundStyle(.secondary)

            if let tokens = message.tokens {
                Text("• \(tokens) tokens")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityLabel("Sent \(relativeTimestamp(message.timestamp))" + (message.tokens.map { ", \($0) tokens" } ?? ""))
    }

    @ViewBuilder
    private var contextMenuItems: some View {
        Button {
            copyToClipboard()
        } label: {
            Label("Copy", systemImage: "doc.on.doc")
        }

        Button {
            shareMessage()
        } label: {
            Label("Share", systemImage: "square.and.arrow.up")
        }

        Button {
            speakMessage()
        } label: {
            Label("Speak", systemImage: "speaker.2")
        }
    }

    // MARK: - Platform-specific styling

    private var platformPadding: EdgeInsets {
#if os(iOS)
        EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
#else
        EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
#endif
    }

    private var bubbleShape: some Shape {
#if os(iOS)
        return AnyShape(RoundedRectangle(cornerRadius: 18))
#else
        return AnyShape(RoundedRectangle(cornerRadius: 12))
#endif
    }

    private var bubbleBorderWidth: CGFloat {
#if os(iOS)
        return 0
#else
        return colorScheme == .dark ? 1 : 0.5
#endif
    }

    // MARK: - Colors

    private var bubbleBackground: some ShapeStyle {
        if hasError {
            return AnyShapeStyle(.red.opacity(0.1))
        }

        switch message.role {
        case .user:
#if os(iOS)
            return AnyShapeStyle(.blue)
#else
            return AnyShapeStyle(colorScheme == .dark ? .blue.opacity(0.8) : .blue)
#endif
        case .assistant:
#if os(iOS)
            return AnyShapeStyle(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
#else
            return AnyShapeStyle(colorScheme == .dark ? Color(.controlBackgroundColor) : .white)
#endif
        case .system:
            return AnyShapeStyle(.orange.opacity(0.2))
        }
    }

    private var bubbleBorderColor: Color {
        if hasError {
            return .red.opacity(0.3)
        }

#if os(iOS)
        return .clear
#else
        return colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.1)
#endif
    }

    private var textColor: Color {
        if hasError {
            return .red
        }

        switch message.role {
        case .user:
            return .white
        case .assistant, .system:
            return .primary
        }
    }

    private var iconColor: Color {
        switch message.role {
        case .user:
            return .blue
        case .assistant:
            return .purple
        case .system:
            return .orange
        }
    }

    private var iconBackgroundColor: Color {
        iconColor.opacity(colorScheme == .dark ? 0.3 : 0.15)
    }

    // MARK: - Computed Properties

    private var hasError: Bool {
        viewModel.currentError != nil && message.role == .assistant
    }

    private var isTyping: Bool {
        viewModel.isResponding && message.role == .assistant && message.content.isEmpty
    }

    // MARK: - Helper functions

    private func parseMarkdown(_ text: String) -> AttributedString {
        do {
            return try AttributedString(markdown: text, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
        } catch {
            return AttributedString(text)
        }
    }

    private func relativeTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private func copyToClipboard() {
#if os(iOS)
        UIPasteboard.general.string = message.content
#else
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(message.content, forType: .string)
#endif
    }

    private func shareMessage() {
        showingShareSheet = true
    }

    private func speakMessage() {
        synthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: message.content)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        synthesizer.speak(utterance)
    }
}

// MARK: - Helper Types

private struct AnyShape: Shape {
    private let _path: (CGRect) -> Path

    init<S: Shape>(_ shape: S) {
        _path = { rect in
            shape.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}

private struct AnyShapeStyle: ShapeStyle {
    private let _resolve: (Environment) -> AnyShapeStyle._Resolved

    init<S: ShapeStyle>(_ style: S) {
        _resolve = { environment in
            AnyShapeStyle._Resolved(style.resolve(in: environment))
        }
    }

    func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        _resolve(Environment(environment))
    }

    private struct Environment {
        let values: EnvironmentValues

        init(_ values: EnvironmentValues) {
            self.values = values
        }
    }

    private struct _Resolved: ShapeStyle {
        private let _resolve: (EnvironmentValues) -> Color

        init<Resolved: ShapeStyle>(_ resolved: Resolved) {
            _resolve = { _ in
                // This is a simplified resolution - in a real implementation,
                // you'd want to handle this more thoroughly
                if let color = resolved as? Color {
                    return color
                } else {
                    return .primary
                }
            }
        }

        func resolve(in environment: EnvironmentValues) -> Color {
            _resolve(environment)
        }
    }
}

// MARK: - Preview

#Preview("User Message") {
    @State var viewModel = ChatViewModel()

    return MessageBubble(
        message: Message(
            content: "Hello! Can you help me with **markdown** formatting?",
            role: .user
        ),
        viewModel: viewModel
    )
    .padding()
}

#Preview("Assistant Message") {
    @State var viewModel = ChatViewModel()

    return MessageBubble(
        message: Message(
            content: "Of course! I can help you with *markdown* formatting. Here are some examples:\n\n- **Bold text**\n- *Italic text*\n- `Code blocks`",
            role: .assistant,
            tokens: 42
        ),
        viewModel: viewModel
    )
    .padding()
}

#Preview("Typing Indicator") {
    @State var viewModel = ChatViewModel()

    return MessageBubble(
        message: Message(
            content: "",
            role: .assistant
        ),
        viewModel: viewModel
    )
    .padding()
}

#Preview("Error State") {
    @State var viewModel = ChatViewModel()

    return MessageBubble(
        message: Message(
            content: "This message failed to send",
            role: .user
        ),
        viewModel: viewModel
    )
    .padding()
}

#Preview("Dark Mode") {
    @State var viewModel = ChatViewModel()

    return VStack(spacing: 16) {
        MessageBubble(
            message: Message(
                content: "User message in dark mode",
                role: .user
            ),
            viewModel: viewModel
        )

        MessageBubble(
            message: Message(
                content: "Assistant response with **markdown** support",
                role: .assistant,
                tokens: 23
            ),
            viewModel: viewModel
        )
    }
    .padding()
    .preferredColorScheme(.dark)
}