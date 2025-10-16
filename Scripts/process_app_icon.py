#!/usr/bin/env python3
"""
Process the 1.png file and generate all required app icon sizes for iOS and macOS
Then copy them to the Xcode assets catalog
"""

import os
import shutil
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("Installing Pillow...")
    os.system("pip3 install Pillow")
    from PIL import Image

def generate_icon_sizes(source_path, output_dir):
    """Generate all required icon sizes from source image"""

    # Load source image
    source = Image.open(source_path).convert("RGBA")

    # Ensure output directory exists
    output_dir.mkdir(parents=True, exist_ok=True)

    # Icon specifications for iOS and macOS
    # Format: (size, scale, filename, platform)
    icon_specs = [
        # iOS Universal (1024x1024)
        (1024, 1, "ios-marketing-1024x1024@1x.png", "ios"),

        # iOS App Icon sizes (for backward compatibility)
        (60, 2, "iphone-60x60@2x.png", "ios"),      # 120x120
        (60, 3, "iphone-60x60@3x.png", "ios"),      # 180x180
        (76, 1, "ipad-76x76@1x.png", "ios"),        # 76x76
        (76, 2, "ipad-76x76@2x.png", "ios"),        # 152x152
        (83.5, 2, "ipad-83.5x83.5@2x.png", "ios"),  # 167x167

        # macOS sizes
        (16, 1, "mac-16x16@1x.png", "mac"),
        (16, 2, "mac-16x16@2x.png", "mac"),
        (32, 1, "mac-32x32@1x.png", "mac"),
        (32, 2, "mac-32x32@2x.png", "mac"),
        (128, 1, "mac-128x128@1x.png", "mac"),
        (128, 2, "mac-128x128@2x.png", "mac"),
        (256, 1, "mac-256x256@1x.png", "mac"),
        (256, 2, "mac-256x256@2x.png", "mac"),
        (512, 1, "mac-512x512@1x.png", "mac"),
        (512, 2, "mac-512x512@2x.png", "mac"),
    ]

    generated_files = []

    for base_size, scale, filename, platform in icon_specs:
        # Calculate actual pixel size
        actual_size = int(base_size * scale)

        # Resize image
        resized = source.resize((actual_size, actual_size), Image.Resampling.LANCZOS)

        # Save to output directory
        output_path = output_dir / filename
        resized.save(output_path, "PNG", optimize=True)

        generated_files.append((filename, actual_size, platform))
        print(f"✅ Generated {filename} ({actual_size}x{actual_size})")

    return generated_files

def update_contents_json(assets_dir, generated_files):
    """Update the Contents.json file for the AppIcon asset"""
    import json

    contents_path = assets_dir / "Contents.json"

    # Create the Contents.json structure
    contents = {
        "images": [
            # iOS Universal
            {
                "filename": "ios-marketing-1024x1024@1x.png",
                "idiom": "universal",
                "platform": "ios",
                "size": "1024x1024"
            },
            # macOS icons
            {
                "filename": "mac-16x16@1x.png",
                "idiom": "mac",
                "scale": "1x",
                "size": "16x16"
            },
            {
                "filename": "mac-16x16@2x.png",
                "idiom": "mac",
                "scale": "2x",
                "size": "16x16"
            },
            {
                "filename": "mac-32x32@1x.png",
                "idiom": "mac",
                "scale": "1x",
                "size": "32x32"
            },
            {
                "filename": "mac-32x32@2x.png",
                "idiom": "mac",
                "scale": "2x",
                "size": "32x32"
            },
            {
                "filename": "mac-128x128@1x.png",
                "idiom": "mac",
                "scale": "1x",
                "size": "128x128"
            },
            {
                "filename": "mac-128x128@2x.png",
                "idiom": "mac",
                "scale": "2x",
                "size": "128x128"
            },
            {
                "filename": "mac-256x256@1x.png",
                "idiom": "mac",
                "scale": "1x",
                "size": "256x256"
            },
            {
                "filename": "mac-256x256@2x.png",
                "idiom": "mac",
                "scale": "2x",
                "size": "256x256"
            },
            {
                "filename": "mac-512x512@1x.png",
                "idiom": "mac",
                "scale": "1x",
                "size": "512x512"
            },
            {
                "filename": "mac-512x512@2x.png",
                "idiom": "mac",
                "scale": "2x",
                "size": "512x512"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }

    # Write the Contents.json file
    with open(contents_path, 'w') as f:
        json.dump(contents, f, indent=2)

    print(f"✅ Updated Contents.json")

def main():
    print("🎨 Processing App Icon for Prism...")
    print("=" * 50)

    # Paths
    project_root = Path("/Users/andrewbierman/Code/prism")
    source_image = project_root / "1.png"
    assets_dir = project_root / "Prism" / "Assets.xcassets" / "AppIcon.appiconset"

    # Check if source exists
    if not source_image.exists():
        print(f"❌ Error: {source_image} not found!")
        return

    print(f"📍 Source image: {source_image}")
    print(f"📁 Target directory: {assets_dir}")
    print()

    # Generate all icon sizes
    print("🔄 Generating icon sizes...")
    generated_files = generate_icon_sizes(source_image, assets_dir)

    # Update Contents.json
    print("\n📝 Updating Contents.json...")
    update_contents_json(assets_dir, generated_files)

    print("\n" + "=" * 50)
    print("✨ App icon successfully processed and added to Xcode!")
    print("\n📱 Next steps:")
    print("1. Open Xcode")
    print("2. Clean build folder (Cmd+Shift+K)")
    print("3. Build and run (Cmd+R)")
    print("4. Your new icon should appear!")

    # Also create a copy on Desktop for reference
    desktop_dir = Path.home() / "Desktop" / "PrismAppIcon_Final"
    desktop_dir.mkdir(exist_ok=True)

    print(f"\n📂 Also copying icons to: {desktop_dir}")
    for filename, _, _ in generated_files:
        src = assets_dir / filename
        dst = desktop_dir / filename
        shutil.copy2(src, dst)

    print("✅ Complete!")

if __name__ == "__main__":
    main()