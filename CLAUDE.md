# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter-based digital sliding puzzle game (数字华容道 / Number Huarongdao) with multiple difficulty levels. The game is a number sliding puzzle where players arrange numbered tiles in order by sliding them into an empty space.

## Development Commands

### Flutter Commands
- **Get dependencies**: `flutter pub get`
- **Run in debug mode**: `flutter run`
- **Run on specific device**: `flutter run -d <device_id>`
- **List devices**: `flutter devices`
- **Build APK (release)**: `flutter build apk --release`
- **Build APK (debug)**: `flutter build apk --debug`
- **Clean build**: `flutter clean`
- **Analyze code**: `flutter analyze`

### Git Commands
- **Repository URL**: https://github.com/backearth1/huarongdao
- **Push changes**: `git push origin main`

## Architecture

### Project Structure
```
lib/
├── main.dart                  # App entry point, MaterialApp configuration
├── models/
│   └── puzzle_model.dart      # Game state and logic
└── screens/
    ├── home_screen.dart       # Difficulty selection screen
    └── game_screen.dart       # Main game interface
```

### Core Components

#### PuzzleModel (lib/models/puzzle_model.dart)
The game engine that handles:
- **Tile representation**: Uses a 1D list where 0 represents the empty tile
- **Shuffling**: Performs random valid moves to ensure solvability (never generates unsolvable puzzles)
- **Move validation**: Checks if a tile is adjacent to the empty space
- **Win detection**: Verifies if all tiles are in correct order (1, 2, 3, ..., N-1, 0)

Key methods:
- `moveTile(int index)`: Attempts to move a tile, returns true if successful
- `canMove(int index)`: Checks if a tile can be moved
- `isSolved()`: Checks if the puzzle is solved
- `reset()`: Reinitializes and reshuffles the puzzle

#### HomeScreen (lib/screens/home_screen.dart)
Displays four difficulty options:
- 简单 (Easy): 3×3 grid
- 中等 (Medium): 4×4 grid
- 困难 (Hard): 5×5 grid
- 专家 (Expert): 6×6 grid

Each button navigates to GameScreen with the selected size.

#### GameScreen (lib/screens/game_screen.dart)
The main game interface featuring:
- **Timer**: Starts on first move, stops when solved
- **Move counter**: Tracks number of moves
- **Grid display**: Responsive grid that adapts to screen size
- **Win dialog**: Shows completion stats (moves and time)
- **Reset button**: Allows restarting the current difficulty

The grid uses `GridView.builder` with color-coded tiles based on their number using HSL color space for visual distinction.

### State Management
Uses StatefulWidget with setState for reactive UI updates. No external state management library is needed for this simple game.

## Android Build Configuration

### Key Files
- `android/app/build.gradle`: App-level build configuration
  - Minimum SDK: 21 (Android 5.0)
  - Target SDK: 34 (Android 14)
  - Package: com.example.huarongdao

- `android/build.gradle`: Project-level build configuration
  - Kotlin version: 1.9.0
  - Gradle plugin: 8.1.0

### Building APK
The release APK will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`

## GitHub Actions CI/CD

The workflow file `.github/workflows/build-apk.yml` automatically:
1. Builds APK on every push to main/master
2. Uploads APK as artifact
3. Creates GitHub releases with the built APK

To trigger a build: Push to main branch or manually trigger via GitHub Actions UI.

## Game Logic Details

### Solvability
The puzzle shuffling ensures solvability by performing random valid moves from the solved state, rather than randomly arranging tiles. This guarantees that every generated puzzle can be solved.

### Coordinate System
Tiles are stored in a 1D list but conceptually represent a 2D grid:
- Index to row: `row = index ~/ size`
- Index to column: `col = index % size`
- 2D to index: `index = row * size + col`

### Adjacent Tile Detection
A tile can move if it's horizontally or vertically adjacent to the empty space:
- Same row, adjacent column: `row == emptyRow && abs(col - emptyCol) == 1`
- Same column, adjacent row: `col == emptyCol && abs(row - emptyRow) == 1`
