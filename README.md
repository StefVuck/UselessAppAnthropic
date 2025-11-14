# UselessApp - Wheel of Doom

A chaotic file browser where opening files is a gamble. Features a spinning roulette wheel that determines your file's fate.

## Features

### Wheel of Doom
- **50% chance**: File opens normally
- **45% chance**: File gets teleported to random folder
- **5% chance**: File gets sent to shadow realm (recoverable)

Built with realistic physics, dramatic animations, and anxiety-inducing suspense.

## Requirements
- macOS 14.0+
- Xcode 15.0+
- Swift 5.0+

## Getting Started

### Quick Run
```bash
open UselessApp.xcodeproj
# Press Cmd+R in Xcode to build and run
```

### Command Line Build
```bash
xcodebuild -project UselessApp.xcodeproj -scheme UselessApp -configuration Debug build
open ~/Library/Developer/Xcode/DerivedData/UselessApp-*/Build/Products/Debug/UselessApp.app
```

## How It Works

1. App creates sandbox folder at `~/Documents/ChaoticPlayground`
2. Sample files are generated on first run
3. Click any file to summon the Wheel of Doom
4. Spin the wheel and watch your file's fate unfold
5. All operations are reversible:
   - Teleported files: `~/Documents/ChaoticPlayground/Teleported/`
   - Deleted files: `~/.ChaoticTrash/`

## Project Structure
```
UselessApp/
├── Models/
│   ├── FileItem.swift           # File representation
│   └── WheelOutcome.swift       # Outcome probabilities
├── Views/
│   ├── FilePickerView.swift     # File browser
│   ├── WheelOfDoomView.swift    # Main wheel interface
│   └── Components/
│       └── WheelSegments.swift  # Wheel graphics
├── UselessAppApp.swift          # App entry
└── ContentView.swift            # Root view
```

## Safety Features
- All operations confined to sandbox folder
- Deleted files moved to `.ChaoticTrash` (not permanently deleted)
- Teleported files leave breadcrumb trail
- Sample files created for testing
- No actual data loss possible

## Implementation Details
- Realistic wheel physics with 4-second spin animation
- Weighted random outcomes (50/45/5 split)
- SwiftUI animations with spring physics
- FileManager operations for safe file handling
- Sandboxed entitlements for file access

## License
Do whatever you want with this. It's chaotic anyway.
