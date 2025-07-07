# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PencilLetters is an iOS/iPadOS app for collecting handwritten letter samples, designed for training ML models for crossword puzzle handwriting recognition. The app uses SwiftUI and PencilKit to capture letter drawings and saves them as grayscale PNG images.

## Development Commands

This is an Xcode project. Use these commands:

### Xcode GUI:
- Build: `Cmd+B`
- Run: `Cmd+R`
- Test: `Cmd+U`

### Command Line:
```bash
# Build the project
xcodebuild -project PencilLetters.xcodeproj -scheme PencilLetters build

# Run tests
xcodebuild -project PencilLetters.xcodeproj -scheme PencilLetters test

# Clean build
xcodebuild -project PencilLetters.xcodeproj -scheme PencilLetters clean
```

## Architecture

The app follows a simple SwiftUI architecture with three main components:

1. **ContentView.swift** (274 lines) - Main UI and business logic
   - Manages letter selection, sample counting, and file operations
   - Handles the workflow: random letter → draw → save → next letter
   - Tracks progress (up to 100 samples per letter A-Z)

2. **PencilKitView.swift** (75 lines) - UIViewRepresentable wrapper
   - Bridges UIKit's PKCanvasView to SwiftUI
   - Configures Apple Pencil-only input with black ink (20pt width)
   - Provides 600x600 canvas with 3x3 grid overlay

3. **ImageProcessing.swift** (63 lines) - Drawing utilities
   - Converts PKDrawing to UIImage
   - Applies grayscale conversion
   - Outputs 224x224 PNG images for ML training

## Key Implementation Details

- **File Storage**: Saves to `/Documents/{Letter}/{Letter}_0001.png` format
- **Canvas**: 600x600 pixels with grid overlay simulating crossword cells
- **Output**: 224x224 grayscale PNG images
- **Workflow**: Automatic progression through incomplete letters
- **File Sharing**: Enabled via Info.plist for data export

## Testing

Uses Apple's Swift Testing framework. Tests are located in:
- `PencilLettersTests/` - Unit tests
- `PencilLettersUITests/` - UI tests