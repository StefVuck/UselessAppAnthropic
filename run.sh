#!/bin/bash

# Wheel of Doom Launcher Script
# Builds and launches the Chaotic Finder app

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "🎡 Building Wheel of Doom..."
echo ""

xcodebuild -project UselessApp.xcodeproj \
    -scheme UselessApp \
    -configuration Release \
    -derivedDataPath ./build \
    clean build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo "🚀 Launching Wheel of Doom..."
    echo ""

    APP_PATH="./build/Build/Products/Release/UselessApp.app"

    if [ -d "$APP_PATH" ]; then
        open "$APP_PATH"
        echo "🎯 App launched! Prepare for chaos..."
    else
        echo "❌ Error: App not found at $APP_PATH"
        exit 1
    fi
else
    echo "❌ Build failed!"
    exit 1
fi
