# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build the package
swift build

# Run all tests (uses Apple's Testing framework, not XCTest)
swift test

# Run SwiftLint (strict mode as per CI)
swiftlint --strict

# Build in release mode
swift build -c release
```

## Architecture

SwiftUIToast is a toast notification library for SwiftUI with queue management and customizable animations.

### Core Components

- **ToastManager** (`@Observable`, `@MainActor`): Central queue manager that displays toasts sequentially. Maintains a queue of toast IDs with configurable max size (default 10). Share via `.environment(toastManager)`.

- **ToastModifier**: Core ViewModifier that integrates with ToastManager, handles visibility state, auto-dismiss timing, tap-to-dismiss, and animation application.

- **ToastConfiguration**: Struct for appearance/behavior settings (duration, position, tapToDismiss, animation). Has presets: `.standard`, `.top`, `.bottom`, `.bouncy()`, `.fade()`, `.flip()`.

- **ToastAnimation**: Animation types (slide, fade, scale, bounce, flip, slideWithBounce).

- **View+Toast**: Extension providing two main modifiers:
  - `.toast(isPresented:message:type:)` for predefined toasts
  - `.toast(isPresented:configuration:content:)` for custom content

### Platform Requirements

- Swift 6.0+ (with Swift 5 compatibility)
- iOS 17.0+, macOS 14.0+, tvOS 17.0+
- Xcode 15.0+

### Testing

Tests use Apple's `Testing` framework (not XCTest). Test files are in `Tests/SwiftUIToastTests/` with `AsyncExpectation.swift` providing test utilities for async operations.

## Code Style

SwiftLint enforced with strict mode. Key rules:
- Line length: 120 warning, 150 error
- File length: 500 warning, 1200 error
- Function body: 50 warning, 100 error
