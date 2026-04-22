# WordGuesser

The project was made as a final project on the [Stanford 193p course](https://cs193p.stanford.edu/).

## Overview

WordGuesser is a small iOS app built with SwiftUI for playing a word guessing game.
The app loads common English words from [Stanford CS193p word list](https://web.stanford.edu/class/cs193p/common.words) and uses them as secret words for the game, so some features may not work correctly without internet access.

The current project target supports iPhone and iPad.

<img width="295" height="640" alt="Simulator Screen Recording - iPhone 17 Pro - 2026-04-22 at 09 16 54" src="https://github.com/user-attachments/assets/ca9d40a2-8769-44f4-b44f-9308d7dcd94c" />

## Features

- Create and manage multiple word guessing games
- Choose a word length from 3 to 6 letters
- Resume saved games from the game list
- Search games by current guess or previous attempts
- Filter games completed
- Track attempts, last attempt preview, and elapsed play time
- Validate guesses as real English words
- Get exact, inexact, and no-match feedback for each letter
- Restart a game
- Customize match colors and shape in the settings
- Persist the games with SwiftData
- Persist UI preferences with `UserDefaults`
- Add sample games on first launch
- Use a split view layout that works well on iPad

## Skills

- SwiftUI, 
- SwiftData, 
- `@Observable`, 
- `NavigationSplitView`, 
- async/await, 
- environment values, 
- `UserDefaults`, 
- state management, 
- animations, 

## How to Run

1. Open `WordGuesser.xcodeproj` in Xcode.
2. Select the `WordGuesser` scheme.
3. Choose an iPhone simulator or a connected iPhone.
4. Press `Cmd + R` to build and run the app.
