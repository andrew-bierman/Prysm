//
//  View+Extensions.swift
//  prism
//
//  Created by Andrew Bierman on 10/15/25.
//

import SwiftUI

// MARK: - Platform-Adaptive Modifiers
extension View {

    /// Applies platform-specific navigation styling
    @ViewBuilder
    func platformNavigationStyle() -> some View {
        #if os(macOS)
        self.navigationSplitViewStyle(.balanced)
        #elseif os(iOS)
        self.navigationBarTitleDisplayMode(.large)
        #elseif os(visionOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    /// Applies platform-appropriate toolbar styling
    @ViewBuilder
    func platformToolbarStyle() -> some View {
        #if os(macOS)
        self.toolbar(.visible, for: .windowToolbar)
        #elseif os(iOS)
        self.toolbarBackground(.visible, for: .navigationBar)
        #else
        self
        #endif
    }

    /// Applies platform-specific padding
    @ViewBuilder
    func platformPadding() -> some View {
        #if os(macOS)
        self.padding(.horizontal, 20)
             .padding(.vertical, 16)
        #elseif os(iOS)
        self.padding(.horizontal, 16)
             .padding(.vertical, 12)
        #elseif os(visionOS)
        self.padding(.horizontal, 24)
             .padding(.vertical, 20)
        #else
        self.padding()
        #endif
    }

    /// Applies platform-appropriate corner radius
    @ViewBuilder
    func platformCornerRadius() -> some View {
        #if os(macOS)
        self.clipShape(RoundedRectangle(cornerRadius: 8))
        #elseif os(iOS)
        self.clipShape(RoundedRectangle(cornerRadius: 12))
        #elseif os(visionOS)
        self.clipShape(RoundedRectangle(cornerRadius: 16))
        #else
        self.clipShape(RoundedRectangle(cornerRadius: 8))
        #endif
    }
}

// MARK: - Glass Effect Helpers
extension View {

    /// Applies a glass morphism effect with platform-appropriate styling
    @ViewBuilder
    func glassEffect(intensity: Double = 0.8) -> some View {
        #if os(macOS)
        self.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        #elseif os(iOS)
        self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
        #elseif os(visionOS)
        self.background(.thickMaterial, in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
        #else
        self.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        #endif
    }

    /// Applies a frosted glass background
    @ViewBuilder
    func frostedBackground() -> some View {
        #if os(macOS)
        self.background(.thinMaterial.opacity(0.7))
        #elseif os(iOS)
        self.background(.ultraThinMaterial.opacity(0.8))
        #elseif os(visionOS)
        self.background(.regularMaterial.opacity(0.9))
        #else
        self.background(.thinMaterial)
        #endif
    }
}

// MARK: - Conditional View Extensions
extension View {

    /// Conditionally applies a view modifier
    @ViewBuilder
    func `if`<T>(_ condition: Bool, transform: (Self) -> T) -> some View where T: View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Conditionally applies one of two view modifiers
    @ViewBuilder
    func `if`<T, F>(_ condition: Bool, then: (Self) -> T, else: (Self) -> F) -> some View
    where T: View, F: View {
        if condition {
            then(self)
        } else {
            `else`(self)
        }
    }

    /// Applies a modifier only on specific platforms
    @ViewBuilder
    func onPlatform<T>(_ platforms: Platform..., apply modifier: (Self) -> T) -> some View
    where T: View {
        if platforms.contains(Platform.current) {
            modifier(self)
        } else {
            self
        }
    }
}

// MARK: - Platform-Specific Colors and Materials
extension View {

    /// Applies platform-appropriate accent color
    @ViewBuilder
    func platformAccentColor() -> some View {
        #if os(macOS)
        self.tint(.blue)
        #elseif os(iOS)
        self.tint(.accentColor)
        #elseif os(visionOS)
        self.tint(.white)
        #else
        self.tint(.accentColor)
        #endif
    }

    /// Applies platform-specific background material
    @ViewBuilder
    func platformBackgroundMaterial() -> some View {
        #if os(macOS)
        self.background(.regularMaterial)
        #elseif os(iOS)
        self.background(.thickMaterial)
        #elseif os(visionOS)
        self.background(.ultraThickMaterial)
        #else
        self.background(.regularMaterial)
        #endif
    }

    /// Applies platform-appropriate selection styling
    @ViewBuilder
    func platformSelectionStyle() -> some View {
        #if os(macOS)
        self.background(.selection.opacity(0.3), in: RoundedRectangle(cornerRadius: 6))
        #elseif os(iOS)
        self.background(.selection.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
        #elseif os(visionOS)
        self.background(.selection.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
        #else
        self.background(.selection, in: RoundedRectangle(cornerRadius: 8))
        #endif
    }
}

// MARK: - Window Sizing Helpers for macOS
#if os(macOS)
extension View {

    /// Sets ideal window size for macOS
    @ViewBuilder
    func idealWindowSize(width: CGFloat = 800, height: CGFloat = 600) -> some View {
        self.frame(idealWidth: width, idealHeight: height)
    }

    /// Sets minimum window size for macOS
    @ViewBuilder
    func minimumWindowSize(width: CGFloat = 400, height: CGFloat = 300) -> some View {
        self.frame(minWidth: width, minHeight: height)
    }

    /// Sets maximum window size for macOS
    @ViewBuilder
    func maximumWindowSize(width: CGFloat = 1200, height: CGFloat = 800) -> some View {
        self.frame(maxWidth: width, maxHeight: height)
    }

    /// Applies common window sizing constraints
    @ViewBuilder
    func standardWindowSizing() -> some View {
        self.frame(
            minWidth: 400, idealWidth: 800, maxWidth: 1200,
            minHeight: 300, idealHeight: 600, maxHeight: 800
        )
    }

    /// Makes the window resizable with custom constraints
    @ViewBuilder
    func resizableWindow(
        minWidth: CGFloat = 400,
        minHeight: CGFloat = 300,
        maxWidth: CGFloat = .infinity,
        maxHeight: CGFloat = .infinity
    ) -> some View {
        self.frame(
            minWidth: minWidth, maxWidth: maxWidth,
            minHeight: minHeight, maxHeight: maxHeight
        )
    }
}
#endif

// MARK: - Responsive Design Helpers
extension View {

    /// Applies responsive layout based on screen size
    @ViewBuilder
    func responsiveLayout() -> some View {
        #if os(macOS)
        self.frame(maxWidth: .infinity, maxHeight: .infinity)
        #elseif os(iOS)
        GeometryReader { geometry in
            if geometry.size.width > 600 {
                // iPad layout
                self.padding(.horizontal, 40)
            } else {
                // iPhone layout
                self.padding(.horizontal, 16)
            }
        }
        #elseif os(visionOS)
        self.frame(width: 800, height: 600)
        #else
        self
        #endif
    }

    /// Applies adaptive spacing based on platform
    @ViewBuilder
    func adaptiveSpacing() -> some View {
        #if os(macOS)
        VStack(spacing: 12) { self }
        #elseif os(iOS)
        VStack(spacing: 16) { self }
        #elseif os(visionOS)
        VStack(spacing: 20) { self }
        #else
        VStack(spacing: 12) { self }
        #endif
    }
}

// MARK: - Accessibility Helpers
extension View {

    /// Applies platform-appropriate accessibility modifiers
    @ViewBuilder
    func platformAccessibility(label: String, hint: String? = nil) -> some View {
        self.accessibilityLabel(label)
            .if(hint != nil) { view in
                view.accessibilityHint(hint!)
            }
            .accessibilityAddTraits(.isButton)
    }

    /// Configures platform-specific focus behavior
    @ViewBuilder
    func platformFocusBehavior() -> some View {
        #if os(macOS)
        self.focusable()
        #elseif os(iOS)
        self.focusable()
        #else
        self
        #endif
    }
}

// MARK: - Animation Helpers
extension View {

    /// Applies platform-appropriate spring animation
    @ViewBuilder
    func platformSpringAnimation() -> some View {
        #if os(macOS)
        self.animation(.spring(response: 0.5, dampingFraction: 0.8), value: true)
        #elseif os(iOS)
        self.animation(.spring(response: 0.3, dampingFraction: 0.7), value: true)
        #elseif os(visionOS)
        self.animation(.spring(response: 0.4, dampingFraction: 0.75), value: true)
        #else
        self.animation(.spring(), value: true)
        #endif
    }

    /// Applies smooth transition animation
    @ViewBuilder
    func smoothTransition() -> some View {
        #if os(macOS)
        self.transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
        #elseif os(iOS)
        self.transition(.slide)
        #elseif os(visionOS)
        self.transition(.scale.combined(with: .opacity))
        #else
        self.transition(.opacity)
        #endif
    }
}