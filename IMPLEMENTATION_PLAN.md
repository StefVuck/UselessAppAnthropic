# Chaotic Finder - Implementation Plan

## Overview
Build a parody file browser with three main chaotic features that make file management unpredictable and anxiety-inducing.

## Architecture

### App Flow
```
Launch App
    ↓
DictationLoginView (Voice-only authentication)
    ↓
ChaoticFinderView (Main file browser)
    ↓
    ├─→ Folder selected → Shuffles contents → FolderShuffleView
    └─→ File selected → WheelOfDoomView → (Open/Teleport/Delete)
```

### Data Models

**FileItem.swift**
```swift
struct FileItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let path: URL
    let size: Int64
    let isDirectory: Bool
    let creationDate: Date
    var displayName: String  // Can differ from actual name for chaos
}
```

**WheelOutcome.swift**
```swift
enum WheelOutcome: String, CaseIterable {
    case open = "OPEN"
    case teleport = "TELEPORT"
    case delete = "DELETE"

    var color: Color {
        switch self {
        case .open: return .green
        case .teleport: return .yellow
        case .delete: return .red
        }
    }

    var probability: Double {
        switch self {
        case .open: return 0.50
        case .teleport: return 0.45
        case .delete: return 0.05
        }
    }
}
```

**ShuffleType.swift**
```swift
enum ShuffleType: String, CaseIterable {
    case random = "Random Chaos"
    case reverseAlpha = "Z→A"
    case sizeSort = "Tiny First"
    case extensionChaos = "Extension Madness"
    case dateChaos = "Time Traveler"
    case fibonacci = "Fibonacci Positions"
}
```

### Services

**DictationService.swift**
- Manages Speech framework integration
- Handles microphone permissions
- Provides real-time transcription
- Compares spoken input to expected credentials
- Tracks failed attempts

**FileSystemService.swift**
- Safe file operations within sandbox
- Creates and manages ~/Documents/ChaoticPlayground
- Maintains operation manifest for undo
- Handles file moves (teleport)
- Manages .ChaoticTrash folder for "deleted" files

**ShuffleManager.swift**
- Implements shuffle algorithms
- Maintains shuffle history
- Provides undo functionality
- Tracks statistics (shuffles per day, etc)

## Implementation Phases

### Phase 1: Core Setup & File Browser
**Files to create:**
- Models/FileItem.swift
- Services/FileSystemService.swift
- Views/ChaoticFinderView.swift

**Tasks:**
1. Set up FileSystemService with sandbox directory creation
2. Implement FileItem model with file enumeration
3. Build basic ChaoticFinderView with list of files/folders
4. Add navigation between folders
5. Add file icons and metadata display

**Entitlements needed:**
```xml
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

### Phase 2: Dictation Login
**Files to create:**
- Services/DictationService.swift
- Views/DictationLoginView.swift

**Tasks:**
1. Request microphone permissions
2. Implement Speech recognition service
3. Build login UI with microphone visualization
4. Add real-time transcription display
5. Implement credential comparison logic
6. Add comedy messaging for failed attempts
7. Create bypass mechanism (voice command "I give up")
8. Add demo credentials: "test" / "test"

**Entitlements needed:**
```xml
<key>com.apple.security.device.audio-input</key>
<true/>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Required for voice authentication (it's a joke app)</string>
<key>NSMicrophoneUsageDescription</key>
<string>Required for voice authentication (it's a joke app)</string>
```

**Info.plist additions:**
- NSSpeechRecognitionUsageDescription
- NSMicrophoneUsageDescription

### Phase 3: Folder Shuffle
**Files to create:**
- Models/ShuffleType.swift
- Services/ShuffleManager.swift
- Views/FolderShuffleView.swift

**Tasks:**
1. Implement ShuffleManager with all shuffle algorithms
2. Add shuffle animation to folder view
3. Display shuffle type indicator
4. Implement statistics tracking
5. Add "undo" that just re-shuffles
6. Create smooth transitions between shuffles

**Animation details:**
- Use `.transition()` with asymmetric insertion/removal
- Spring animation for file movement
- Shuffle type announcement with fade-in
- Stats counter animation

### Phase 4: Wheel of Doom
**Files to create:**
- Models/WheelOutcome.swift
- Views/WheelOfDoomView.swift
- Views/Components/WheelSegments.swift
- Views/Components/OutcomeResultView.swift

**Tasks:**
1. Build wheel UI with three colored segments
2. Implement rotation physics and animation
3. Add weighted random outcome selection
4. Implement file operations (open/teleport/delete)
5. Add sound effects (optional)
6. Build result screens for each outcome
7. Add teleportation tracker
8. Implement .ChaoticTrash recovery system

**Animation details:**
- Custom timing curve for realistic deceleration
- Rotation calculation to land on specific outcome
- Pointer bounce animation at end
- Segment highlighting during spin

### Phase 5: Polish & Safety
**Tasks:**
1. Add comprehensive error handling
2. Implement operation manifest for full undo
3. Add confirmation dialogs for "dangerous" operations
4. Create settings panel with safety toggles
5. Add statistics dashboard
6. Implement "Training Wheels" mode
7. Add achievement system (optional comedy feature)
8. Create help/about screen

## Technical Requirements

### Frameworks
```swift
import SwiftUI
import Speech           // Voice recognition
import AVFoundation     // Audio engine, sound effects
import AppKit           // NSWorkspace for file operations
```

### Permissions Required
1. Microphone access - for dictation
2. Speech recognition - for voice authentication
3. File system access - for sandbox folder operations

### Sandbox Strategy
- Primary operations in ~/Documents/ChaoticPlayground
- Creates folder structure on first launch
- All destructive operations logged in manifest.json
- .ChaoticTrash folder for "deleted" files
- Breadcrumb files for teleported items

### Performance Considerations
- Lazy loading for large directories
- Async file enumeration
- Debounced shuffle to prevent rapid triggering
- Efficient file metadata caching

## Testing Strategy

### Unit Tests
- ShuffleManager algorithms
- FileSystemService operations
- WheelOutcome probability distribution
- Path manipulation utilities

### Manual Testing Checklist
- [ ] Dictation works with various accents
- [ ] Folder shuffle maintains file integrity
- [ ] Wheel probabilities feel correct
- [ ] All file operations are reversible
- [ ] No actual data loss possible
- [ ] Sandbox isolation works correctly
- [ ] Permissions requested appropriately

### Edge Cases
- Empty folders
- Very large directories (1000+ files)
- Read-only files
- System folders (should be blocked)
- Symlinks
- Hidden files

## Development Order

1. **Day 1-2**: Core file browser + FileSystemService
2. **Day 3-4**: Dictation login screen
3. **Day 5-6**: Folder shuffle implementation
4. **Day 7-8**: Wheel of Doom
5. **Day 9-10**: Polish, safety, testing

## Safety Guarantees

### Hard Rules
1. NEVER operate outside ~/Documents/ChaoticPlayground
2. NEVER permanently delete files (only move to .ChaoticTrash)
3. ALWAYS maintain operation manifest
4. ALWAYS provide undo mechanism
5. REQUIRE explicit user consent for file operations

### Default Behaviors
- Simulation mode by default
- Confirmation dialogs before first actual file operation
- Clear visual indicators when in "safe mode" vs "chaos mode"
- One-click "restore all" function

## UI/UX Design

### Color Scheme
- Background: Dark mode friendly
- Open (success): Green (#34C759)
- Teleport (warning): Yellow (#FFD60A)
- Delete (danger): Red (#FF3B30)
- Neutral: System gray

### Typography
- Headers: SF Pro Display Bold
- Body: SF Pro Text Regular
- Monospace: SF Mono (for file paths)

### Animations
- Wheel spin: 4 seconds with ease-out
- Folder shuffle: 0.5s spring animation
- Login feedback: Immediate with bounce
- All interactive elements have hover states

## Future Enhancements (Optional)

1. Multi-user profiles with different chaos preferences
2. "Chaos Score" leaderboard
3. Export statistics as shareable image
4. Custom shuffle algorithm creator
5. File preview before wheel spin
6. Achievements and badges
7. Dark/light mode toggle
8. Customizable wheel probabilities
9. Sound pack options
10. "Extreme Mode" with more chaos options
