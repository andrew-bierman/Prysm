//
//  Platform+Extensions.swift
//  prism
//
//  Created by Andrew Bierman on 10/15/25.
//

import SwiftUI
import Foundation

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

// MARK: - Platform Enumeration
enum Platform: String, CaseIterable, Sendable {
    case macOS = "macOS"
    case iOS = "iOS"
    case visionOS = "visionOS"
    case watchOS = "watchOS"
    case tvOS = "tvOS"

    /// Returns the current platform
    static var current: Platform {
        #if os(macOS)
        return .macOS
        #elseif os(iOS)
        return .iOS
        #elseif os(visionOS)
        return .visionOS
        #elseif os(watchOS)
        return .watchOS
        #elseif os(tvOS)
        return .tvOS
        #else
        return .macOS // Default fallback
        #endif
    }

    /// Returns a human-readable display name
    var displayName: String {
        switch self {
        case .macOS:
            return "macOS"
        case .iOS:
            return "iOS"
        case .visionOS:
            return "visionOS"
        case .watchOS:
            return "watchOS"
        case .tvOS:
            return "tvOS"
        }
    }

    /// Returns the platform icon name
    var iconName: String {
        switch self {
        case .macOS:
            return "desktopcomputer"
        case .iOS:
            return "iphone"
        case .visionOS:
            return "visionpro"
        case .watchOS:
            return "applewatch"
        case .tvOS:
            return "appletv"
        }
    }
}

// MARK: - Device Detection Helpers
struct DeviceInfo: Sendable {

    /// Returns true if running on a Mac
    static var isMac: Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }

    /// Returns true if running on iOS (iPhone or iPad)
    static var isiOS: Bool {
        #if os(iOS)
        return true
        #else
        return false
        #endif
    }

    /// Returns true if running on visionOS
    static var isVisionOS: Bool {
        #if os(visionOS)
        return true
        #else
        return false
        #endif
    }

    /// Returns true if running on watchOS
    static var isWatchOS: Bool {
        #if os(watchOS)
        return true
        #else
        return false
        #endif
    }

    /// Returns true if running on tvOS
    static var isTvOS: Bool {
        #if os(tvOS)
        return true
        #else
        return false
        #endif
    }

    /// Returns true if running on iPhone (not iPad)
    static var isPhone: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone
        #else
        return false
        #endif
    }

    /// Returns true if running on iPad
    static var isPad: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad
        #else
        return false
        #endif
    }

    /// Returns true if the device supports touch input
    static var isTouchDevice: Bool {
        return isiOS || isVisionOS
    }

    /// Returns true if the device has a physical keyboard by default
    static var hasPhysicalKeyboard: Bool {
        return isMac || isTvOS
    }

    /// Returns true if the device supports multi-window
    static var supportsMultiWindow: Bool {
        return isMac || isPad || isVisionOS
    }

    /// Returns the device model name
    static var modelName: String {
        #if os(macOS)
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
        #elseif os(iOS)
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value))!)
        }
        return identifier
        #else
        return "Unknown"
        #endif
    }
}

// MARK: - Platform Name Helpers
extension Platform {

    /// Returns the marketing name for the current device
    static var marketingName: String {
        switch Platform.current {
        case .macOS:
            return "Mac"
        case .iOS:
            #if os(iOS)
            if DeviceInfo.isPad {
                return "iPad"
            } else {
                return "iPhone"
            }
            #else
            return "iOS Device"
            #endif
        case .visionOS:
            return "Apple Vision Pro"
        case .watchOS:
            return "Apple Watch"
        case .tvOS:
            return "Apple TV"
        }
    }

    /// Returns the full platform version string
    static var versionString: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }

    /// Returns just the major version number
    static var majorVersion: Int {
        return ProcessInfo.processInfo.operatingSystemVersion.majorVersion
    }

    /// Returns the OS name with version
    static var fullOSName: String {
        return "\(Platform.current.displayName) \(versionString)"
    }
}

// MARK: - OS Version Helpers
struct OSVersion: Sendable {

    /// Returns true if running iOS 17 or later
    static var isiOS17OrLater: Bool {
        #if os(iOS)
        return ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 17
        #else
        return false
        #endif
    }

    /// Returns true if running macOS 14 (Sonoma) or later
    static var isSonomaOrLater: Bool {
        #if os(macOS)
        return ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 14
        #else
        return false
        #endif
    }

    /// Returns true if running visionOS 1 or later
    static var isVisionOS1OrLater: Bool {
        #if os(visionOS)
        return ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 1
        #else
        return false
        #endif
    }

    /// Checks if the current OS version meets the minimum requirement
    static func meetsMinimumVersion(major: Int, minor: Int = 0, patch: Int = 0) -> Bool {
        let currentVersion = ProcessInfo.processInfo.operatingSystemVersion

        if currentVersion.majorVersion > major {
            return true
        } else if currentVersion.majorVersion == major {
            if currentVersion.minorVersion > minor {
                return true
            } else if currentVersion.minorVersion == minor {
                return currentVersion.patchVersion >= patch
            }
        }

        return false
    }

    /// Returns availability info for features
    static func isFeatureAvailable(_ feature: OSFeature) -> Bool {
        switch feature {
        case .swiftUI4:
            #if os(macOS)
            return meetsMinimumVersion(major: 13)
            #elseif os(iOS)
            return meetsMinimumVersion(major: 16)
            #else
            return true
            #endif
        case .swiftUI5:
            #if os(macOS)
            return meetsMinimumVersion(major: 14)
            #elseif os(iOS)
            return meetsMinimumVersion(major: 17)
            #else
            return true
            #endif
        case .navigationStack:
            #if os(macOS)
            return meetsMinimumVersion(major: 13)
            #elseif os(iOS)
            return meetsMinimumVersion(major: 16)
            #else
            return true
            #endif
        }
    }
}

enum OSFeature: Sendable {
    case swiftUI4
    case swiftUI5
    case navigationStack
}

// MARK: - Platform-Specific Constants
struct PlatformConstants {

    /// Standard spacing values for each platform
    enum Spacing {
        static let small: CGFloat = {
            switch Platform.current {
            case .macOS: return 8
            case .iOS: return 12
            case .visionOS: return 16
            case .watchOS: return 6
            case .tvOS: return 10
            }
        }()

        static let medium: CGFloat = {
            switch Platform.current {
            case .macOS: return 16
            case .iOS: return 20
            case .visionOS: return 24
            case .watchOS: return 12
            case .tvOS: return 20
            }
        }()

        static let large: CGFloat = {
            switch Platform.current {
            case .macOS: return 24
            case .iOS: return 32
            case .visionOS: return 40
            case .watchOS: return 18
            case .tvOS: return 30
            }
        }()
    }

    /// Standard corner radius values
    enum CornerRadius {
        static let small: CGFloat = {
            switch Platform.current {
            case .macOS: return 6
            case .iOS: return 8
            case .visionOS: return 12
            case .watchOS: return 4
            case .tvOS: return 8
            }
        }()

        static let medium: CGFloat = {
            switch Platform.current {
            case .macOS: return 8
            case .iOS: return 12
            case .visionOS: return 16
            case .watchOS: return 6
            case .tvOS: return 12
            }
        }()

        static let large: CGFloat = {
            switch Platform.current {
            case .macOS: return 12
            case .iOS: return 16
            case .visionOS: return 20
            case .watchOS: return 8
            case .tvOS: return 16
            }
        }()
    }

    /// Standard font sizes
    enum FontSize {
        static let caption: CGFloat = {
            switch Platform.current {
            case .macOS: return 11
            case .iOS: return 12
            case .visionOS: return 14
            case .watchOS: return 10
            case .tvOS: return 16
            }
        }()

        static let body: CGFloat = {
            switch Platform.current {
            case .macOS: return 13
            case .iOS: return 17
            case .visionOS: return 19
            case .watchOS: return 14
            case .tvOS: return 24
            }
        }()

        static let title: CGFloat = {
            switch Platform.current {
            case .macOS: return 20
            case .iOS: return 28
            case .visionOS: return 32
            case .watchOS: return 18
            case .tvOS: return 40
            }
        }()
    }
}

// MARK: - Screen Size Helpers
struct ScreenInfo {

    /// Returns the main screen size
    static var size: CGSize {
        #if os(macOS)
        return NSScreen.main?.frame.size ?? CGSize(width: 1920, height: 1080)
        #elseif os(iOS)
        return UIScreen.main.bounds.size
        #else
        return CGSize(width: 800, height: 600) // Default fallback
        #endif
    }

    /// Returns the screen width
    static var width: CGFloat {
        return size.width
    }

    /// Returns the screen height
    static var height: CGFloat {
        return size.height
    }

    /// Returns the screen scale factor
    static var scale: CGFloat {
        #if os(macOS)
        return NSScreen.main?.backingScaleFactor ?? 1.0
        #elseif os(iOS)
        return UIScreen.main.scale
        #else
        return 1.0
        #endif
    }

    /// Returns true if the screen is in landscape orientation
    static var isLandscape: Bool {
        return width > height
    }

    /// Returns true if the screen is considered "large"
    static var isLargeScreen: Bool {
        switch Platform.current {
        case .macOS:
            return width >= 1920
        case .iOS:
            return width >= 768 // iPad size
        case .visionOS:
            return true
        case .watchOS:
            return false
        case .tvOS:
            return true
        }
    }

    /// Returns a size category for the screen
    static var sizeCategory: ScreenSizeCategory {
        switch Platform.current {
        case .macOS:
            if width >= 2560 { return .extraLarge }
            else if width >= 1920 { return .large }
            else if width >= 1440 { return .medium }
            else { return .small }
        case .iOS:
            if DeviceInfo.isPad {
                return width >= 1024 ? .large : .medium
            } else {
                return width >= 414 ? .medium : .small
            }
        case .visionOS:
            return .large
        case .watchOS:
            return .small
        case .tvOS:
            return .extraLarge
        }
    }
}

enum ScreenSizeCategory: Sendable {
    case small, medium, large, extraLarge
}

// MARK: - Haptic Feedback Helpers
struct HapticManager {

    /// Triggers light haptic feedback if supported
    static func light() {
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        #endif
    }

    /// Triggers medium haptic feedback if supported
    static func medium() {
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        #endif
    }

    /// Triggers heavy haptic feedback if supported
    static func heavy() {
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        #endif
    }

    /// Triggers success haptic feedback if supported
    static func success() {
        #if os(iOS)
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
        #endif
    }

    /// Triggers error haptic feedback if supported
    static func error() {
        #if os(iOS)
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.error)
        #endif
    }

    /// Triggers warning haptic feedback if supported
    static func warning() {
        #if os(iOS)
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.warning)
        #endif
    }
}