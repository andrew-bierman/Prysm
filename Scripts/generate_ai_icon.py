#!/usr/bin/env python3
"""
Generate AI-focused app icons for Prism
Creates a modern chat + AI design
"""

import os
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFont, ImageFilter
    import numpy as np
except ImportError:
    print("Installing required packages...")
    os.system("pip3 install Pillow numpy")
    from PIL import Image, ImageDraw, ImageFont, ImageFilter
    import numpy as np

def create_ai_chat_icon():
    """Create a modern AI chat icon with gradient and effects"""
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Create radial gradient background (dark purple to light purple)
    center_x, center_y = size // 2, size // 2
    for y in range(size):
        for x in range(size):
            # Calculate distance from center
            distance = np.sqrt((x - center_x)**2 + (y - center_y)**2)
            max_distance = np.sqrt(center_x**2 + center_y**2)
            ratio = min(distance / max_distance, 1.0)

            # Gradient from light purple center to dark purple edges
            r = int(120 - 40 * ratio)   # 120 to 80
            g = int(80 - 30 * ratio)    # 80 to 50
            b = int(200 - 50 * ratio)   # 200 to 150

            draw.point((x, y), (r, g, b, 255))

    # Draw chat bubble
    bubble_size = int(size * 0.5)
    bubble_x = int(size * 0.25)
    bubble_y = int(size * 0.3)

    # Main bubble with rounded rectangle
    corner_radius = int(bubble_size * 0.2)
    draw.rounded_rectangle(
        [(bubble_x, bubble_y), (bubble_x + bubble_size, bubble_y + bubble_size * 0.7)],
        radius=corner_radius,
        fill=(255, 255, 255, 230),
        outline=(255, 255, 255, 255),
        width=3
    )

    # Chat bubble tail
    tail_points = [
        (bubble_x + bubble_size * 0.15, bubble_y + bubble_size * 0.65),
        (bubble_x + bubble_size * 0.05, bubble_y + bubble_size * 0.85),
        (bubble_x + bubble_size * 0.3, bubble_y + bubble_size * 0.7),
    ]
    draw.polygon(tail_points, fill=(255, 255, 255, 230))

    # Draw AI sparkles/dots inside bubble (representing thinking/processing)
    dot_positions = [
        (0.3, 0.4),
        (0.5, 0.4),
        (0.7, 0.4),
    ]

    for i, (dx, dy) in enumerate(dot_positions):
        dot_x = bubble_x + bubble_size * dx
        dot_y = bubble_y + bubble_size * dy
        dot_size = int(size * 0.04)

        # Animated effect - middle dot slightly larger
        if i == 1:
            dot_size = int(dot_size * 1.3)

        # Gradient dots from purple to pink
        colors = [(147, 51, 234), (236, 72, 153), (59, 130, 246)]
        color = colors[i % len(colors)]

        draw.ellipse(
            [(dot_x - dot_size, dot_y - dot_size),
             (dot_x + dot_size, dot_y + dot_size)],
            fill=color
        )

    # Add subtle glow effect around bubble
    glow = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)

    for i in range(5):
        alpha = int(30 - i * 5)
        offset = i * 5
        glow_draw.rounded_rectangle(
            [(bubble_x - offset, bubble_y - offset),
             (bubble_x + bubble_size + offset, bubble_y + bubble_size * 0.7 + offset)],
            radius=corner_radius + offset,
            fill=(255, 255, 255, alpha)
        )

    # Composite glow behind main image
    final = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    final.paste(glow, (0, 0))
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

def create_alternate_icon():
    """Create an alternate design with brain/neural network concept"""
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Gradient background (blue to purple)
    for y in range(size):
        ratio = y / size
        r = int(59 + (147 - 59) * ratio)    # Blue to purple
        g = int(130 - (130 - 51) * ratio)
        b = int(246 - (246 - 234) * ratio)
        draw.rectangle([(0, y), (size, y+1)], fill=(r, g, b, 255))

    # Draw neural network nodes
    nodes = [
        (0.3, 0.3), (0.7, 0.3),  # Top layer
        (0.2, 0.5), (0.5, 0.5), (0.8, 0.5),  # Middle layer
        (0.3, 0.7), (0.7, 0.7),  # Bottom layer
    ]

    connections = [
        (0, 2), (0, 3), (1, 3), (1, 4),  # Top to middle
        (2, 5), (3, 5), (3, 6), (4, 6),  # Middle to bottom
    ]

    # Draw connections first (behind nodes)
    for start_idx, end_idx in connections:
        start = nodes[start_idx]
        end = nodes[end_idx]
        draw.line(
            [(size * start[0], size * start[1]),
             (size * end[0], size * end[1])],
            fill=(255, 255, 255, 100),
            width=3
        )

    # Draw nodes
    for i, (x, y) in enumerate(nodes):
        node_size = int(size * 0.06)

        # Center node (brain) is larger and different
        if i == 3:  # Middle center node
            node_size = int(size * 0.12)
            # Draw brain-like shape (simplified as circles)
            draw.ellipse(
                [(size * x - node_size, size * y - node_size),
                 (size * x + node_size, size * y + node_size)],
                fill=(255, 255, 255, 255),
                outline=(255, 255, 255, 255),
                width=3
            )
            # Add inner detail
            draw.ellipse(
                [(size * x - node_size * 0.7, size * y - node_size * 0.7),
                 (size * x + node_size * 0.7, size * y + node_size * 0.7)],
                fill=(147, 51, 234, 200)
            )
        else:
            # Regular nodes
            draw.ellipse(
                [(size * x - node_size, size * y - node_size),
                 (size * x + node_size, size * y + node_size)],
                fill=(255, 255, 255, 200),
                outline=(255, 255, 255, 255),
                width=2
            )

    # Add sparkles for AI effect
    sparkle_positions = [(0.15, 0.15), (0.85, 0.15), (0.15, 0.85), (0.85, 0.85)]
    for sx, sy in sparkle_positions:
        # Draw star/sparkle shape
        sparkle_size = int(size * 0.03)
        cx, cy = size * sx, size * sy

        # Four-pointed star
        points = [
            (cx, cy - sparkle_size),  # Top
            (cx + sparkle_size * 0.3, cy - sparkle_size * 0.3),
            (cx + sparkle_size, cy),  # Right
            (cx + sparkle_size * 0.3, cy + sparkle_size * 0.3),
            (cx, cy + sparkle_size),  # Bottom
            (cx - sparkle_size * 0.3, cy + sparkle_size * 0.3),
            (cx - sparkle_size, cy),  # Left
            (cx - sparkle_size * 0.3, cy - sparkle_size * 0.3),
        ]
        draw.polygon(points, fill=(255, 255, 255, 180))

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

    sizes = [16, 32, 64, 128, 256, 512, 1024]

    for size in sizes:
        resized = icon.resize((size, size), Image.Resampling.LANCZOS)
        filename = f"{name_prefix}-{size}x{size}.png"
        output_path = output_dir / filename
        resized.save(output_path, "PNG")
        print(f"Created: {filename}")

def main():
    print("🤖 Generating AI-themed Prism App Icons...")

    # Generate first design - Chat bubble with AI dots
    icon1 = create_ai_chat_icon()
    output_dir1 = Path.home() / "Desktop" / "PrismAppIcons_AI_Chat"
    resize_and_save(icon1, "AppIcon", output_dir1)

    print(f"\n✅ AI Chat icons saved to: {output_dir1}")

    # Generate second design - Neural network
    icon2 = create_alternate_icon()
    output_dir2 = Path.home() / "Desktop" / "PrismAppIcons_AI_Neural"
    resize_and_save(icon2, "AppIcon", output_dir2)

    print(f"✅ Neural Network icons saved to: {output_dir2}")

    print("\n🎨 All icon sets generated successfully!")
    print("\n📁 Available designs:")
    print("1. PrismAppIcons - Simple gradient prism")
    print("2. PrismAppIcons_SF - Prism with light refraction")
    print("3. PrismAppIcons_AI_Chat - Chat bubble with AI indicators")
    print("4. PrismAppIcons_AI_Neural - Neural network design")

if __name__ == "__main__":
    main()