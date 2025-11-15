#!/usr/bin/env python3
"""
Quick script to change app name via AppConfig.swift
"""

import sys
import re
from pathlib import Path

def update_app_name(new_name, new_short_name=None):
    """Update the app name in AppConfig.swift and Xcode project"""

    config_path = Path("/Users/andrewbierman/Code/prism/Prysm/Constants/AppConfig.swift")

    if not config_path.exists():
        print(f"❌ AppConfig.swift not found at {config_path}")
        return False

    with open(config_path, 'r') as f:
        content = f.read()

    # Update app name
    content = re.sub(
        r'static let appName = "[^"]*"',
        f'static let appName = "{new_name}"',
        content
    )

    # Update short name if provided
    if new_short_name:
        content = re.sub(
            r'static let appShortName = "[^"]*"',
            f'static let appShortName = "{new_short_name}"',
            content
        )
    else:
        # Use first word of name as short name
        short = new_name.split()[0]
        content = re.sub(
            r'static let appShortName = "[^"]*"',
            f'static let appShortName = "{short}"',
            content
        )

    # Update assistant name to match
    content = re.sub(
        r'static let assistantName = "[^"]*"',
        f'static let assistantName = "{new_name}"',
        content
    )

    # Update bundle ID base (make it safe for bundle IDs)
    safe_bundle_name = new_name.lower().replace(" ", "-").replace("'", "")
    content = re.sub(
        r'static let bundleIdBase = "[^"]*"',
        f'static let bundleIdBase = "andrewbierman.{safe_bundle_name}"',
        content
    )

    with open(config_path, 'w') as f:
        f.write(content)

    # Also update the Xcode project file
    project_path = Path("/Users/andrewbierman/Code/prism/Prysm.xcodeproj/project.pbxproj")
    if project_path.exists():
        with open(project_path, 'r') as f:
            project_content = f.read()

        # Update PRODUCT_NAME
        project_content = re.sub(
            r'PRODUCT_NAME = "[^"]*"',
            f'PRODUCT_NAME = "{new_name}"',
            project_content
        )

        # Update CFBundleDisplayName
        project_content = re.sub(
            r'INFOPLIST_KEY_CFBundleDisplayName = "[^"]*"',
            f'INFOPLIST_KEY_CFBundleDisplayName = "{new_name}"',
            project_content
        )

        # Update PRODUCT_BUNDLE_IDENTIFIER
        project_content = re.sub(
            r'PRODUCT_BUNDLE_IDENTIFIER = "[^"]*"',
            f'PRODUCT_BUNDLE_IDENTIFIER = "andrewbierman.{safe_bundle_name}"',
            project_content
        )

        # Update target names in comments (these show in Xcode UI)
        project_content = project_content.replace('/* Prism */', f'/* {new_name} */')
        project_content = project_content.replace('/* PrismTests */', f'/* {new_name}Tests */')
        project_content = project_content.replace('/* PrismUITests */', f'/* {new_name}UITests */')

        # Update build configuration lists
        project_content = project_content.replace('"Prism"', f'"{new_name}"')
        project_content = project_content.replace('"PrismTests"', f'"{new_name}Tests"')
        project_content = project_content.replace('"PrismUITests"', f'"{new_name}UITests"')

        # Update TEST_TARGET_NAME
        project_content = project_content.replace('TEST_TARGET_NAME = Prism;', f'TEST_TARGET_NAME = "{new_name}";')

        with open(project_path, 'w') as f:
            f.write(project_content)

        print(f"✅ Updated Xcode project settings")

    print(f"✅ Updated app name to: {new_name}")
    if new_short_name:
        print(f"   Short name: {new_short_name}")
    print(f"   Bundle ID: andrewbierman.{safe_bundle_name}")

    return True

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 change_app_name.py 'New App Name' [short_name]")
        print("\nExamples:")
        print("  python3 change_app_name.py 'Luma AI'")
        print("  python3 change_app_name.py 'Spectrum AI' 'Spectrum'")
        print("  python3 change_app_name.py 'Prysm'")
        print("\nSuggested unique names:")
        print("  • Luma AI")
        print("  • Prysm")
        print("  • Spectrum AI")
        print("  • Refract AI")
        print("  • Flux AI")
        print("  • Radiant AI")
        print("  • Photon AI")
        print("  • Aurora AI")
        return

    new_name = sys.argv[1]
    short_name = sys.argv[2] if len(sys.argv) > 2 else None

    if update_app_name(new_name, short_name):
        print("\n📝 Next steps:")
        print("1. Clean build folder in Xcode (Cmd+Shift+K)")
        print("2. Build and run (Cmd+R)")
        print("\nNote: The app name change is now centralized in AppConfig.swift")
        print("All UI elements will automatically use the new name!")

if __name__ == "__main__":
    main()