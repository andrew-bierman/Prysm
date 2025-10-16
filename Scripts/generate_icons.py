#!/usr/bin/env python3
"""
Generate app icons for Prism
Creates all required sizes for iOS and macOS
"""

import os
import subprocess
from pathlib import Path

# Icon sizes needed for iOS and macOS
icon_sizes = {
    # iOS - Universal
    "ios_universal": [(1024, 1024)],

    # macOS
    "mac": [
        (16, 16),
        (32, 16),    # 16x16@2x
        (32, 32),
        (64, 32),    # 32x32@2x
        (128, 128),
        (256, 128),  # 128x128@2x
        (256, 256),
        (512, 256),  # 256x256@2x
        (512, 512),
        (1024, 512), # 512x512@2x
    ]
}

def create_icon_with_text():
    """Create a simple icon using ImageMagick or PIL"""
    try:
        from PIL import Image, ImageDraw, ImageFont
        import numpy as np

        # Create base icon at 1024x1024
        size = 1024
        img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)

        # Create gradient background
        for y in range(size):
            # Purple to pink gradient
            r = int(102 + (153 - 102) * (y / size))  # Purple to pink red channel
            g = int(51 + (102 - 51) * (y / size))     # Purple to pink green channel
            b = int(204 - (204 - 153) * (y / size))  # Purple to pink blue channel
            draw.rectangle([(0, y), (size, y+1)], fill=(r, g, b, 255))

        # Draw prism shape
        prism_points = [
            (size * 0.5, size * 0.2),   # Top
            (size * 0.25, size * 0.7),  # Bottom left
            (size * 0.75, size * 0.7),  # Bottom right
        ]
        draw.polygon(prism_points, fill=(255, 255, 255, 200), outline=(255, 255, 255, 255), width=8)

        # Add some inner lines for 3D effect
        draw.line([(size * 0.5, size * 0.2), (size * 0.5, size * 0.8)], fill=(255, 255, 255, 150), width=4)
        draw.line([(size * 0.25, size * 0.7), (size * 0.5, size * 0.8)], fill=(255, 255, 255, 150), width=4)
        draw.line([(size * 0.75, size * 0.7), (size * 0.5, size * 0.8)], fill=(255, 255, 255, 150), width=4)

        # Round corners for iOS
        # Create a mask for rounded corners
        mask = Image.new('L', (size, size), 0)
        mask_draw = ImageDraw.Draw(mask)
        corner_radius = int(size * 0.2237)  # iOS corner radius ratio
        mask_draw.rounded_rectangle([(0, 0), (size, size)], corner_radius, fill=255)

        # Apply mask
        output = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        output.paste(img, (0, 0), mask)

        return output

    except ImportError:
        print("PIL not found. Trying ImageMagick...")
        return None

def create_icon_with_imagemagick():
    """Fallback: Create icon using ImageMagick command line"""
    output_path = Path.home() / "Desktop" / "AppIcon-1024x1024.png"

    commands = [
        # Create gradient background
        f"convert -size 1024x1024 gradient:'#6633CC'-'#CC6699' '{output_path}'",

        # Add prism shape overlay
        f"convert '{output_path}' -fill 'rgba(255,255,255,0.8)' -stroke white -strokewidth 8 "
        f"-draw 'polygon 512,204 256,716 768,716' '{output_path}'",

        # Round corners
        f"convert '{output_path}' -alpha set -background none "
        f"-fill white -draw 'roundrectangle 0,0 1024,1024 229,229' "
        f"-compose DstIn -composite '{output_path}'"
    ]

    for cmd in commands:
        try:
            subprocess.run(cmd, shell=True, check=True)
            return str(output_path)
        except subprocess.CalledProcessError:
            continue

    return None

def resize_icon(source_image, sizes_dict, output_dir):
    """Resize the source icon to all required sizes"""
    from PIL import Image

    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    if isinstance(source_image, str):
        img = Image.open(source_image)
    else:
        img = source_image

    for category, sizes in sizes_dict.items():
        for size_tuple in sizes:
            if len(size_tuple) == 2:
                width, name_size = size_tuple
                height = width
            else:
                width, height, name_size = size_tuple

            resized = img.resize((width, height), Image.Resampling.LANCZOS)

            if category == "ios_universal":
                filename = f"AppIcon-{width}x{height}.png"
            else:
                # macOS naming convention
                if width == name_size:
                    filename = f"AppIcon-{name_size}x{name_size}.png"
                else:
                    scale = width // name_size
                    filename = f"AppIcon-{name_size}x{name_size}@{scale}x.png"

            output_path = output_dir / filename
            resized.save(output_path, "PNG")
            print(f"Created: {filename}")

def main():
    print("🎨 Generating Prism App Icons...")

    # Try to create the icon
    icon = create_icon_with_text()

    if icon:
        # Save the base icon
        base_path = Path.home() / "Desktop" / "PrismAppIcons"
        base_path.mkdir(exist_ok=True)

        base_icon_path = base_path / "AppIcon-1024x1024.png"
        icon.save(base_icon_path)
        print(f"✅ Created base icon: {base_icon_path}")

        # Generate all sizes
        resize_icon(icon, icon_sizes, base_path)

        print("\n📦 Icon generation complete!")
        print(f"📁 Icons saved to: {base_path}")
        print("\n📝 Next steps:")
        print("1. Open Xcode and navigate to Assets.xcassets")
        print("2. Select AppIcon")
        print("3. Drag and drop the generated icons to their respective slots")
        print("4. For iOS: Use AppIcon-1024x1024.png for the universal slot")
        print("5. For macOS: Use the appropriately sized icons for each slot")

    else:
        print("❌ Could not generate icon. Please install PIL: pip install Pillow")
        print("   Or install ImageMagick: brew install imagemagick")

if __name__ == "__main__":
    main()