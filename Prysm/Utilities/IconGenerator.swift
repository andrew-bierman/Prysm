//
//  IconGenerator.swift
//  Prism
//
//  Generates app icon programmatically
//

import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct AppIconView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.2, blue: 0.8),  // Purple
                    Color(red: 0.6, green: 0.3, blue: 0.9),  // Light purple
                    Color(red: 0.8, green: 0.4, blue: 0.7),  // Pink
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Luma AI shape overlay
            PrismShape()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.9),
                            Color.white.opacity(0.3)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .scaleEffect(0.6)
                .shadow(color: Color.black.opacity(0.3), radius: size * 0.02, x: 0, y: size * 0.01)

            // AI sparkles
            SparklesOverlay()
                .foregroundStyle(Color.white.opacity(0.8))
                .scaleEffect(0.8)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.2237))  // iOS app icon corner radius
    }
}

struct PrismShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        // Create a triangular prism shape
        // Top point
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.15))

        // Bottom left
        path.addLine(to: CGPoint(x: width * 0.25, y: height * 0.75))

        // Bottom right
        path.addLine(to: CGPoint(x: width * 0.75, y: height * 0.75))

        // Close the triangle
        path.closeSubpath()

        // Add inner lines for 3D effect
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.15))
        path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.85))

        path.move(to: CGPoint(x: width * 0.25, y: height * 0.75))
        path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.85))

        path.move(to: CGPoint(x: width * 0.75, y: height * 0.75))
        path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.85))

        return path
    }
}

struct SparklesOverlay: View {
    var body: some View {
        ZStack {
            Image(systemName: "sparkle")
                .font(.system(size: 30))
                .offset(x: -40, y: -30)
                .rotationEffect(.degrees(-15))

            Image(systemName: "sparkle")
                .font(.system(size: 20))
                .offset(x: 35, y: -45)
                .rotationEffect(.degrees(25))

            Image(systemName: "sparkle")
                .font(.system(size: 25))
                .offset(x: 45, y: 35)
                .rotationEffect(.degrees(-30))

            Image(systemName: "sparkle")
                .font(.system(size: 15))
                .offset(x: -35, y: 40)
                .rotationEffect(.degrees(45))
        }
    }
}

struct AlternativeAppIconView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            // Gradient background
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.5, green: 0.3, blue: 0.9),  // Center purple
                    Color(red: 0.3, green: 0.1, blue: 0.7),  // Dark purple edge
                ]),
                center: .center,
                startRadius: 0,
                endRadius: size * 0.7
            )

            // Chat bubble with prism effect
            ChatBubblePrism()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.95),
                            Color.cyan.opacity(0.3),
                            Color.purple.opacity(0.3),
                            Color.pink.opacity(0.3),
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(0.7)
                .shadow(color: Color.black.opacity(0.3), radius: size * 0.02)

            // AI brain symbol
            Image(systemName: "brain")
                .font(.system(size: size * 0.3, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white,
                            Color.white.opacity(0.8)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color.purple.opacity(0.5), radius: 4)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.2237))
    }
}

struct ChatBubblePrism: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let cornerRadius = min(width, height) * 0.15

        // Create rounded rectangle for chat bubble
        let bubbleRect = CGRect(
            x: width * 0.15,
            y: height * 0.25,
            width: width * 0.7,
            height: height * 0.5
        )

        path.addRoundedRect(in: bubbleRect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))

        // Add tail
        path.move(to: CGPoint(x: width * 0.35, y: height * 0.72))
        path.addLine(to: CGPoint(x: width * 0.25, y: height * 0.85))
        path.addLine(to: CGPoint(x: width * 0.45, y: height * 0.75))

        return path
    }
}

// Preview for SwiftUI
#Preview("App Icons") {
    VStack(spacing: 20) {
        Text("Option 1: Prism Shape")
            .font(.headline)
        AppIconView(size: 256)
            .frame(width: 256, height: 256)

        Text("Option 2: Chat + AI Brain")
            .font(.headline)
        AlternativeAppIconView(size: 256)
            .frame(width: 256, height: 256)
    }
    .padding()
}

// MARK: - Export Functionality

#if os(macOS)
extension NSImage {
    func pngData() -> Data? {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let rep = NSBitmapImageRep(cgImage: cgImage)
        return rep.representation(using: .png, properties: [:])
    }
}

@MainActor
func exportAppIcon() {
    let sizes = [
        // iOS
        1024,
        // macOS
        16, 32, 64, 128, 256, 512, 1024
    ]

    for size in sizes {
        let iconView = AppIconView(size: CGFloat(size))

        let renderer = ImageRenderer(content: iconView)
        renderer.scale = 1.0

        if let nsImage = renderer.nsImage {
            if let data = nsImage.pngData() {
                let filename = "AppIcon-\(size)x\(size).png"
                let url = URL(fileURLWithPath: NSHomeDirectory())
                    .appendingPathComponent("Desktop")
                    .appendingPathComponent(filename)

                try? data.write(to: url)
                print("Exported: \(filename)")
            }
        }
    }
}
#endif