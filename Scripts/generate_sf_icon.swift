#!/usr/bin/env swift

import Foundation
import CoreGraphics
import AppKit

// Create a more sophisticated icon using SF Symbols and gradients
func createPrismIcon(size: CGFloat) -> NSImage? {
    let image = NSImage(size: NSSize(width: size, height: size))

    image.lockFocus()

    // Create gradient background
    let gradient = NSGradient(colors: [
        NSColor(red: 0.4, green: 0.2, blue: 0.8, alpha: 1.0),  // Deep purple
        NSColor(red: 0.6, green: 0.3, blue: 0.9, alpha: 1.0),  // Medium purple
        NSColor(red: 0.9, green: 0.4, blue: 0.7, alpha: 1.0),  // Pink
    ])

    let rect = NSRect(x: 0, y: 0, width: size, height: size)

    // Draw rounded rectangle background
    let cornerRadius = size * 0.2237 // iOS corner radius
    let roundedPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    gradient?.draw(in: roundedPath, angle: -45.0)

    // Draw prism shape
    let prismPath = NSBezierPath()

    // Main triangle
    prismPath.move(to: NSPoint(x: size * 0.5, y: size * 0.8))     // Top
    prismPath.line(to: NSPoint(x: size * 0.25, y: size * 0.3))    // Bottom left
    prismPath.line(to: NSPoint(x: size * 0.75, y: size * 0.3))    // Bottom right
    prismPath.close()

    // Set prism color with transparency
    NSColor.white.withAlphaComponent(0.9).setFill()
    prismPath.fill()

    // Draw inner lines for 3D effect
    NSColor.white.withAlphaComponent(0.5).setStroke()
    prismPath.lineWidth = size * 0.01

    let innerPath = NSBezierPath()
    innerPath.move(to: NSPoint(x: size * 0.5, y: size * 0.8))
    innerPath.line(to: NSPoint(x: size * 0.5, y: size * 0.2))

    innerPath.move(to: NSPoint(x: size * 0.25, y: size * 0.3))
    innerPath.line(to: NSPoint(x: size * 0.5, y: size * 0.2))

    innerPath.move(to: NSPoint(x: size * 0.75, y: size * 0.3))
    innerPath.line(to: NSPoint(x: size * 0.5, y: size * 0.2))

    innerPath.lineWidth = size * 0.008
    innerPath.stroke()

    // Add light refraction effect (rainbow colors on edges)
    let colors = [
        NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.3),   // Red
        NSColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.3),   // Orange
        NSColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.3),   // Yellow
        NSColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.3),   // Green
        NSColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.3),   // Cyan
        NSColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.3),   // Blue
        NSColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 0.3),   // Purple
    ]

    // Draw rainbow refraction on left edge
    let leftEdgePath = NSBezierPath()
    leftEdgePath.move(to: NSPoint(x: size * 0.5, y: size * 0.8))
    leftEdgePath.line(to: NSPoint(x: size * 0.25, y: size * 0.3))
    leftEdgePath.lineWidth = size * 0.015

    for (index, color) in colors.enumerated() {
        let offset = CGFloat(index - 3) * size * 0.003
        let offsetPath = NSBezierPath()
        offsetPath.move(to: NSPoint(x: size * 0.5 + offset, y: size * 0.8))
        offsetPath.line(to: NSPoint(x: size * 0.25 + offset, y: size * 0.3))
        offsetPath.lineWidth = size * 0.002
        color.setStroke()
        offsetPath.stroke()
    }

    image.unlockFocus()
    return image
}

// Generate icons in multiple sizes
func generateIcons() {
    let sizes = [16, 32, 64, 128, 256, 512, 1024]
    let desktop = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Desktop")
        .appendingPathComponent("PrismAppIcons_SF")

    try? FileManager.default.createDirectory(at: desktop, withIntermediateDirectories: true)

    for size in sizes {
        if let icon = createPrismIcon(size: CGFloat(size)) {
            let url = desktop.appendingPathComponent("AppIcon-\(size)x\(size).png")

            if let tiffData = icon.tiffRepresentation,
               let bitmapRep = NSBitmapImageRep(data: tiffData),
               let pngData = bitmapRep.representation(using: .png, properties: [:]) {
                try? pngData.write(to: url)
                print("Generated: AppIcon-\(size)x\(size).png")
            }
        }
    }

    print("\n✅ Icons generated at: \(desktop.path)")
}

// Run the generator
generateIcons()