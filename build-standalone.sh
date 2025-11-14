#!/bin/bash

# Build standalone Wheel of Doom app bundle
# Creates a distributable .app in the Builds folder

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

OUTPUT_DIR="$SCRIPT_DIR/Builds"
APP_NAME="UselessFinder"

echo "🎡 Building Standalone Wheel of Doom App..."
echo ""

mkdir -p "$OUTPUT_DIR"

# Clean first without the custom output dir to avoid errors
xcodebuild -project UselessApp.xcodeproj \
    -scheme UselessApp \
    -configuration Release \
    -derivedDataPath ./build \
    clean > /dev/null 2>&1 || true

# Then build to custom output dir
xcodebuild -project UselessApp.xcodeproj \
    -scheme UselessApp \
    -configuration Release \
    -derivedDataPath ./build \
    CONFIGURATION_BUILD_DIR="$OUTPUT_DIR" \
    build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"

    APP_PATH="$OUTPUT_DIR/UselessApp.app"
    NEW_APP_PATH="$OUTPUT_DIR/$APP_NAME.app"

    if [ -d "$APP_PATH" ]; then
        if [ -d "$NEW_APP_PATH" ]; then
            rm -rf "$NEW_APP_PATH"
        fi

        mv "$APP_PATH" "$NEW_APP_PATH"

        echo ""
        echo "📦 Standalone app created at:"
        echo "   $NEW_APP_PATH"
        echo ""
        echo "🎯 You can now:"
        echo "   - Double-click to run"
        echo "   - Drag to Applications folder"
        echo "   - Share with friends (if you hate them)"
        echo ""

        open "$OUTPUT_DIR"
    else
        echo "❌ Error: App not found at $APP_PATH"
        exit 1
    fi
else
    echo "❌ Build failed!"
    exit 1
fi
