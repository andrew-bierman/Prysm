#!/usr/bin/env python3
"""
Rebrand the app from Prism to a new name
"""

import os
import re
from pathlib import Path

def update_project_file(file_path, old_name, new_name, old_bundle, new_bundle):
    """Update the Xcode project file"""
    with open(file_path, 'r') as f:
        content = f.read()

    # Update product name
    content = re.sub(f'PRODUCT_NAME = {old_name};', f'PRODUCT_NAME = "{new_name}";', content)

    # Update bundle identifier
    content = content.replace(f'{old_bundle}.prism', f'{new_bundle}')
    content = content.replace(f'{old_bundle}.prismTests', f'{new_bundle}Tests')
    content = content.replace(f'{old_bundle}.prismUITests', f'{new_bundle}UITests')

    # Update display name references
    content = content.replace('"Prism"', f'"{new_name}"')

    with open(file_path, 'w') as f:
        f.write(content)

    print(f"✅ Updated {file_path}")

def update_swift_files(directory, old_name, new_name):
    """Update Swift files with new branding"""
    swift_files = Path(directory).rglob("*.swift")

    replacements = [
        ('navigationTitle("Prism")', f'navigationTitle("{new_name}")'),
        ('"Welcome to Prism"', f'"Welcome to {new_name}"'),
        ('"Prism"', f'"{new_name}"'),  # General string replacement
        ('// Prism', f'// {new_name}'),  # Comments
    ]

    for swift_file in swift_files:
        try:
            with open(swift_file, 'r') as f:
                content = f.read()

            original_content = content
            for old, new in replacements:
                content = content.replace(old, new)

            if content != original_content:
                with open(swift_file, 'w') as f:
                    f.write(content)
                print(f"✅ Updated {swift_file.name}")
        except Exception as e:
            print(f"⚠️ Could not update {swift_file}: {e}")

def main():
    # Configuration
    old_name = "Prism"
    new_name = "Luma AI"  # Change this to your preferred name
    old_bundle = "andrewbierman"
    new_bundle = "andrewbierman.luma-ai"

    project_root = Path("/Users/andrewbierman/Code/prism")

    print(f"🎨 Rebranding {old_name} to {new_name}")
    print("=" * 50)

    # Update project file
    project_file = project_root / "Prism.xcodeproj" / "project.pbxproj"
    if project_file.exists():
        update_project_file(project_file, old_name, new_name, old_bundle, new_bundle)

    # Update Swift files
    update_swift_files(project_root / "Prism", old_name, new_name)

    print("\n" + "=" * 50)
    print(f"✨ Rebrand complete!")
    print(f"\n📝 Next steps:")
    print(f"1. Open Xcode")
    print(f"2. Clean build folder (Cmd+Shift+K)")
    print(f"3. Update the app icon if needed")
    print(f"4. Build and run")
    print(f"\n💡 New details:")
    print(f"   Name: {new_name}")
    print(f"   Bundle ID: {new_bundle}")

if __name__ == "__main__":
    main()