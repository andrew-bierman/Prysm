#!/usr/bin/env python3
"""
Generate a clean geometric prism icon for Prism app
Creates a proper 3D triangular prism like the SVG reference
"""

import os
from pathlib import Path
import math

try:
    from PIL import Image, ImageDraw, ImageFont, ImageFilter
    import numpy as np
except ImportError:
    print("Installing required packages...")
    os.system("pip3 install Pillow numpy")
    from PIL import Image, ImageDraw, ImageFont, ImageFilter
    import numpy as np

def create_geometric_prism_icon():
    """Create a clean geometric prism icon with gradient background"""
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Create a smooth gradient background (purple to pink/orange)
    for y in range(size):
        # Diagonal gradient for more interest
        for x in range(size):
            # Calculate position for diagonal gradient
            ratio = (x + y) / (size * 2)

            # Purple to pink/coral gradient
            r = int(102 + (255 - 102) * ratio)  # 102 to 255
            g = int(51 + (130 - 51) * ratio)    # 51 to 130
            b = int(153 + (150 - 153) * ratio)  # 153 to 150

            draw.point((x, y), (r, g, b, 255))

    # Define the 3D prism vertices (triangular prism)
    # Positioned to be centered and at a nice viewing angle
    cx, cy = size * 0.5, size * 0.5  # Center point
    scale = size * 0.35  # Size of prism

    # Front triangle vertices
    front_top = (cx, cy - scale * 0.8)
    front_left = (cx - scale * 0.7, cy + scale * 0.4)
    front_right = (cx + scale * 0.7, cy + scale * 0.4)

    # Back triangle vertices (offset for 3D effect)
    offset_x = scale * 0.15
    offset_y = -scale * 0.1
    back_top = (front_top[0] + offset_x, front_top[1] + offset_y)
    back_left = (front_left[0] + offset_x, front_left[1] + offset_y)
    back_right = (front_right[0] + offset_x, front_right[1] + offset_y)

    # Draw the prism faces with different shades for 3D effect

    # Back edges (darker, for depth)
    draw.line([back_top, back_left], fill=(255, 255, 255, 100), width=3)
    draw.line([back_left, back_right], fill=(255, 255, 255, 100), width=3)
    draw.line([back_right, back_top], fill=(255, 255, 255, 100), width=3)

    # Right face (lighter shade)
    right_face = [front_right, back_right, back_top, front_top]
    draw.polygon(right_face, fill=(255, 255, 255, 180), outline=None)

    # Bottom face (medium shade)
    bottom_face = [front_left, front_right, back_right, back_left]
    draw.polygon(bottom_face, fill=(255, 255, 255, 150), outline=None)

    # Left face (darkest visible face)
    left_face = [front_left, back_left, back_top, front_top]
    draw.polygon(left_face, fill=(255, 255, 255, 120), outline=None)

    # Front triangle (brightest)
    front_face = [front_top, front_left, front_right]
    draw.polygon(front_face, fill=(255, 255, 255, 220), outline=None)

    # Draw clean edges for definition
    edges = [
        (front_top, front_left),
        (front_left, front_right),
        (front_right, front_top),
        (front_top, back_top),
        (front_left, back_left),
        (front_right, back_right),
    ]

    for start, end in edges:
        draw.line([start, end], fill=(255, 255, 255, 255), width=4)

    # Add subtle shadow beneath the prism
    shadow = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)

    # Create elliptical shadow
    shadow_y = cy + scale * 0.6
    shadow_width = scale * 0.8
    shadow_height = scale * 0.2

    shadow_draw.ellipse(
        [(cx - shadow_width, shadow_y - shadow_height),
         (cx + shadow_width, shadow_y + shadow_height)],
        fill=(0, 0, 0, 50)
    )

    # Apply Gaussian blur to shadow
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=20))

    # Composite shadow under the main image
    final = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    final.paste(shadow, (0, 0))
    final.paste(img, (0, 0), img)

    # Apply iOS corner radius mask
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    corner_radius = int(size * 0.2237)  # iOS corner radius ratio
    mask_draw.rounded_rectangle([(0, 0), (size, size)], corner_radius, fill=255)

    # Apply mask for rounded corners
    output = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    output.paste(final, (0, 0), mask)

    return output

def create_alternate_prism():
    """Create an alternate version with different angle and colors"""
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Different gradient - blue to purple
    for y in range(size):
        ratio = y / size
        r = int(59 + (147 - 59) * ratio)   # Blue to purple
        g = int(130 - (51) * ratio)        # Fade green
        b = int(246 - (234 - 246) * abs(ratio - 0.5) * 2)  # Blue tones
        draw.rectangle([(0, y), (size, y+1)], fill=(r, g, b, 255))

    # Prism at different angle
    cx, cy = size * 0.5, size * 0.45
    scale = size * 0.32

    # More upright prism
    front_top = (cx, cy - scale)
    front_left = (cx - scale * 0.6, cy + scale * 0.6)
    front_right = (cx + scale * 0.6, cy + scale * 0.6)

    # Different 3D offset
    offset_x = scale * 0.25
    offset_y = scale * 0.05
    back_top = (front_top[0] + offset_x, front_top[1] + offset_y)
    back_left = (front_left[0] + offset_x, front_left[1] + offset_y)
    back_right = (front_right[0] + offset_x, front_right[1] + offset_y)

    # Draw faces in different order for different lighting

    # Left face first (darkest)
    left_face = [front_left, back_left, back_top, front_top]
    draw.polygon(left_face, fill=(255, 255, 255, 100), outline=None)

    # Bottom face
    bottom_face = [front_left, front_right, back_right, back_left]
    draw.polygon(bottom_face, fill=(255, 255, 255, 140), outline=None)

    # Right face (brightest side face)
    right_face = [front_right, back_right, back_top, front_top]
    draw.polygon(right_face, fill=(255, 255, 255, 200), outline=None)

    # Front triangle (very bright)
    front_face = [front_top, front_left, front_right]
    draw.polygon(front_face, fill=(255, 255, 255, 240), outline=None)

    # Clean white edges
    all_edges = [
        (front_top, front_left, 5),
        (front_left, front_right, 5),
        (front_right, front_top, 5),
        (front_top, back_top, 3),
        (front_left, back_left, 3),
        (front_right, back_right, 3),
        (back_top, back_left, 2),
        (back_left, back_right, 2),
        (back_right, back_top, 2),
    ]

    for start, end, width in all_edges:
        draw.line([start, end], fill=(255, 255, 255, 255), width=width)

    # Apply iOS corner radius
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    corner_radius = int(size * 0.2237)
    mask_draw.rounded_rectangle([(0, 0), (size, size)], corner_radius, fill=255)

    output = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    output.paste(img, (0, 0), mask)

    return output

def resize_and_save(icon, name_prefix, output_dir):
    """Resize and save icon in all required sizes"""
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    # iOS and macOS sizes
    sizes = [
        (16, "16x16"),
        (32, "16x16@2x"),
        (32, "32x32"),
        (64, "32x32@2x"),
        (128, "128x128"),
        (256, "128x128@2x"),
        (256, "256x256"),
        (512, "256x256@2x"),
        (512, "512x512"),
        (1024, "512x512@2x"),
        (1024, "1024x1024"),
    ]

    for size, name in sizes:
        resized = icon.resize((size, size), Image.Resampling.LANCZOS)
        filename = f"{name_prefix}-{name}.png"
        output_path = output_dir / filename
        resized.save(output_path, "PNG", optimize=True)
        print(f"Created: {filename}")

def main():
    print("💎 Generating Geometric Prism App Icons...")
    print("=" * 50)

    # Generate first design - Classic prism
    print("\n📐 Creating classic geometric prism...")
    icon1 = create_geometric_prism_icon()
    output_dir1 = Path.home() / "Desktop" / "PrismAppIcon_Geometric"
    resize_and_save(icon1, "AppIcon", output_dir1)
    print(f"✅ Saved to: {output_dir1}")

    # Generate alternate design
    print("\n📐 Creating alternate angle prism...")
    icon2 = create_alternate_prism()
    output_dir2 = Path.home() / "Desktop" / "PrismAppIcon_Geometric_Alt"
    resize_and_save(icon2, "AppIcon", output_dir2)
    print(f"✅ Saved to: {output_dir2}")

    print("\n" + "=" * 50)
    print("🎉 Geometric prism icons generated successfully!")
    print("\n📱 To use in Xcode:")
    print("1. Open Assets.xcassets > AppIcon")
    print("2. Drag icons from your chosen folder")
    print("3. Match sizes to appropriate slots")
    print("\n💡 These icons feature:")
    print("• Clean geometric 3D prism shape")
    print("• Professional gradient backgrounds")
    print("• Proper shading for depth")
    print("• Crisp edges at all sizes")

if __name__ == "__main__":
    main()