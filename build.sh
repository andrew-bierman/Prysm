#!/bin/bash

# Build script for Prysm app
# Supports iOS, macOS, and visionOS platforms

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🌈 Building Prysm..."
echo ""

# Default to iOS if no platform specified
PLATFORM=${1:-iOS}

case $PLATFORM in
    iOS|ios)
        echo "📱 Building for iOS Simulator..."
        xcodebuild -project Prysm.xcodeproj \
                   -scheme Prysm \
                   -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
                   clean build
        ;;
    macOS|macos|mac)
        echo "💻 Building for macOS..."
        xcodebuild -project Prysm.xcodeproj \
                   -scheme Prysm \
                   -destination 'platform=macOS' \
                   clean build
        ;;
    visionOS|visionos|vision)
        echo "🥽 Building for visionOS Simulator..."
        xcodebuild -project Prysm.xcodeproj \
                   -scheme Prysm \
                   -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
                   clean build
        ;;
    all)
        echo "🚀 Building for all platforms..."
        $0 iOS
        $0 macOS
        $0 visionOS
        ;;
    *)
        echo -e "${RED}Error: Unknown platform '$PLATFORM'${NC}"
        echo "Usage: ./build.sh [iOS|macOS|visionOS|all]"
        exit 1
        ;;
esac

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Build successful!${NC}"
else
    echo ""
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi