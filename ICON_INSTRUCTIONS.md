# App Icon Instructions

## Icon Design Concept

**Wheel of Doom Icon**: A colorful roulette wheel with danger symbols

### Design Elements:
- Circular wheel divided into colored segments
- Green, Yellow, and Red sections
- Small skull icons in red sections
- Dramatic pointer/arrow at top
- Gradient effects for depth
- Optional: Flames or sparkles around edges

## Creating the Icon

### Option 1: Using SF Symbols (Quick)
macOS can use SF Symbols for app icons during development:

1. Open SF Symbols app (comes with Xcode)
2. Find symbol: "gauge.with.needle" or "circle.hexagongrid.fill"
3. Export at various sizes

### Option 2: Design Custom Icon

**Recommended Tools:**
- Figma (free, web-based)
- Sketch
- Adobe Illustrator
- Pixelmator Pro

**Icon Sizes Needed:**
- 16x16
- 32x32
- 64x64
- 128x128
- 256x256
- 512x512
- 1024x1024 (for Retina displays)

### Option 3: Use Icon Generator Service

**Free online icon generators:**
- https://www.appicon.co/
- https://www.canva.com/
- https://iconifier.net/

Upload a 1024x1024 PNG and it will generate all required sizes.

## Converting to .icns Format

### Method 1: Using iconutil (macOS built-in)

1. Create folder structure:
```bash
mkdir WheelIcon.iconset
```

2. Add images with specific names:
```
icon_16x16.png
icon_16x16@2x.png
icon_32x32.png
icon_32x32@2x.png
icon_128x128.png
icon_128x128@2x.png
icon_256x256.png
icon_256x256@2x.png
icon_512x512.png
icon_512x512@2x.png
```

3. Convert to .icns:
```bash
iconutil -c icns WheelIcon.iconset
```

4. This creates `WheelIcon.icns`

### Method 2: Using sips (quick single image)

```bash
sips -z 1024 1024 original.png --out icon_1024.png
```

## Adding Icon to Xcode Project

1. Open Xcode project
2. Click on `Assets.xcassets`
3. Select `AppIcon`
4. Drag and drop icon files into appropriate size slots
5. Or use Image Set and drag the .icns file

## Quick Test Icon

For testing, you can use an emoji as an icon:

1. Create a 1024x1024 image with an emoji (🎡 or ⚠️)
2. Use TextEdit to save as PDF
3. Convert with Preview or online tool
4. Add to Xcode

## Icon Color Scheme

Based on Wheel of Doom colors:
- **Green**: #34C759 (success/open)
- **Yellow**: #FFD60A (warning/teleport)
- **Red**: #FF3B30 (danger/delete)
- **Background**: Black or dark gradient
- **Accents**: White or metallic silver

## Current Icon Status

The app currently has a placeholder icon. To see it:
```bash
open UselessApp/Assets.xcassets/AppIcon.appiconset/
```

This folder is where you'll place the actual icon images.
