# SwiftUIToast

[![Swift](https://img.shields.io/badge/Swift-5.5+-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.5+-orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-iOS_macOS_tvOS-yellowgreen?style=flat-square)](https://img.shields.io/badge/Platforms-iOS_macOS_tvOS-green?style=flat-square)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)

A customizable toast notification system for SwiftUI, inspired by Android's Toast component. Easily add informative, temporarily displayed messages to your SwiftUI app with beautiful animations and extensive customization options.

## Features

- 🎨 **Predefined Types** – Info, success, and error toasts with appropriate styling
- 🔧 **Custom UI** – Create your own fully customized toast appearance
- ⏱️ **Auto-Dismiss** – Toasts automatically hide after a specified duration
- 👆 **Tap-to-Dismiss** – Dismiss toasts with a simple tap
- 📚 **Queue Management** – Multiple toasts show in sequence
- 🔄 **Custom Animations** – Choose from various entrance/exit animations or create your own
- ♿ **Accessibility Support** – VoiceOver compatible with proper semantic labeling

## Requirements

- iOS 17.0+ / macOS 14.0+ / tvOS 17.0+
- Swift 5.5+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add SwiftUIToast to your project by adding it as a dependency in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/ivan-magda/swiftui-toast.git", from: "1.0.0")
]
```

Or add it directly through Xcode:
1. Go to File > Add Packages...
2. Enter package repository URL: `https://github.com/ivan-magda/swiftui-toast.git`
3. Click "Add Package"

## Usage

### Setup

First, add the `ToastManager` to your app:

```swift
@main
struct MyApp: App {
    @StateObject private var toastManager = ToastManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(toastManager)
        }
    }
}
```

### Basic Toast

```swift
struct ContentView: View {
    @State private var showToast = false
    
    var body: some View {
        Button("Show Toast") {
            showToast = true
        }
        .toast(
            isPresented: $showToast,
            message: "This is a toast message!",
            type: .info
        )
    }
}
```

### Custom Toast

```swift
.toast(isPresented: $showToast, configuration: .top) {
    HStack {
        Image(systemName: "star.fill")
            .foregroundColor(.yellow)
        
        Text("Custom Toast!")
            .bold()
    }
    .padding()
    .background(
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.black.opacity(0.8))
    )
}
```

### Animation Options

```swift
// Different animation types
.toast(
    isPresented: $showBounceToast,
    message: "Bouncy toast!",
    configuration: .bouncy()
)

.toast(
    isPresented: $showFlipToast,
    message: "Flip toast!",
    configuration: .flip()
)

.toast(
    isPresented: $showFadeToast,
    message: "Fade toast!",
    configuration: .fade()
)
```

## Customization

### Toast Configuration

```swift
// Create a custom configuration
let customConfig = ToastConfiguration(
    duration: 5.0,               // Display duration
    position: .top,              // Position on screen
    tapToDismiss: true,          // Allow tap to dismiss
    dismissDelay: 0.2,           // Delay before dismissal animation
    animation: .bounce()         // Animation style
)

// Use the custom configuration
.toast(
    isPresented: $showToast,
    message: "Custom configured toast",
    type: .success,
    configuration: customConfig
)
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
