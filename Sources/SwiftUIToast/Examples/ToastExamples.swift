import SwiftUI

#if DEBUG && os(iOS)
/// Preview for standard toast types
struct TypedToastPreview: View {
    @State private var showToast = false
    @State private var toastType: ToastType = .info

    var body: some View {
        NavigationStack {
            List {
                Button("Info") {
                    toastType = .info
                    showToast = true
                }
                Button("Success") {
                    toastType = .success
                    showToast = true
                }
                Button("Error") {
                    toastType = .error
                    showToast = true
                }
            }
            .navigationTitle("Toast")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Toggle Toast") {
                        showToast.toggle()
                    }
                }
            }
            .toast(
                isPresented: $showToast,
                message: "Test Toast",
                type: toastType
            )
        }
    }
}

#Preview {
    TypedToastPreview()
        .environmentObject(ToastManager())
}

// Example custom toast for feed level up
struct FeedLevelUpToastView: View {
    let level: Int

    var body: some View {
        HStack {
            Image(systemName: "arrow.up.circle.fill")
                .foregroundColor(.green)

            Text("Level up! You reached level \(level)")
                .bold()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.8))
        )
        .foregroundColor(.white)
    }
}

/// Preview for custom toast content
struct CustomToastPreview: View {
    @State private var showToast = false

    var body: some View {
        NavigationStack {
            List {
                Text("Hello, World!")
            }
            .navigationTitle("Toast")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Toggle Toast") {
                        showToast.toggle()
                    }
                }
            }
            .toast(isPresented: $showToast, configuration: .top) {
                FeedLevelUpToastView(level: 5)
            }
        }
    }
}

#Preview {
    CustomToastPreview()
        .environmentObject(ToastManager())
}

/// Preview of the toast queue mechanism
struct ToastPreview: View {
    @State private var showInfoToast = false
    @State private var showSuccessToast = false
    @State private var showErrorToast = false
    @State private var showCustomToast = false

    var body: some View {
        NavigationStack {
            List {
                Section("Standard Toasts") {
                    Button("Show Info Toast") {
                        showInfoToast = true
                    }

                    Button("Show Success Toast") {
                        showSuccessToast = true
                    }

                    Button("Show Error Toast") {
                        showErrorToast = true
                    }
                }

                Section("Queue Testing") {
                    Button("Show Multiple Toasts") {
                        // This will queue them up
                        showInfoToast = true

                        // Delay to make the test more visible
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showSuccessToast = true

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showErrorToast = true

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showCustomToast = true
                                }
                            }
                        }
                    }
                }

                Section("Custom Toast") {
                    Button("Show Custom Toast") {
                        showCustomToast = true
                    }
                }
            }
            .navigationTitle("Toast Demo")
            // Apply all toast modifiers
            .toast(
                isPresented: $showInfoToast,
                message: "Information toast message",
                type: .info
            )
            .toast(
                isPresented: $showSuccessToast,
                message: "Success toast message",
                type: .success
            )
            .toast(
                isPresented: $showErrorToast,
                message: "Error toast message",
                type: .error
            )
            .toast(
                isPresented: $showCustomToast,
                configuration: .top
            ) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "star.fill")
                                .foregroundColor(.white)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Custom Toast")
                            .font(.headline)

                        Text("This is a completely custom toast")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.systemBackground).opacity(0.95))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
            }
        }
    }
}

#Preview {
    ToastPreview()
        .environmentObject(ToastManager())
}

/// Preview of different animation types
struct AnimatedToastExamples: View {
    @State private var showFadeToast = false
    @State private var showBounceToast = false
    @State private var showFlipToast = false
    @State private var showSlideToast = false
    @State private var showSlideWithBounceToast = false

    public var body: some View {
        NavigationStack {
            List {
                Section("Animation Types") {
                    Button("Fade Animation") {
                        showFadeToast = true
                    }

                    Button("Bounce Animation") {
                        showBounceToast = true
                    }

                    Button("Flip Animation") {
                        showFlipToast = true
                    }

                    Button("Slide Animation") {
                        showSlideToast = true
                    }

                    Button("Slide With Bounce") {
                        showSlideWithBounceToast = true
                    }
                }
            }
            .navigationTitle("Toast Animations")
            // Apply all custom toast animations
            .toast(
                isPresented: $showFadeToast,
                message: "Fade animation toast",
                configuration: .fade()
            )
            .toast(
                isPresented: $showBounceToast,
                message: "Bounce animation toast",
                configuration: .bouncy()
            )
            .toast(
                isPresented: $showFlipToast,
                message: "Flip animation toast",
                configuration: .flip()
            )
            .toast(
                isPresented: $showSlideToast,
                message: "Slide animation toast",
                configuration: ToastConfiguration(
                    position: .bottom,
                    animation: .slide(edge: .bottom)
                )
            )
            .toast(
                isPresented: $showSlideWithBounceToast,
                message: "Slide with bounce animation",
                configuration: ToastConfiguration(
                    position: .top,
                    animation: .slideWithBounce(edge: .top)
                )
            )
        }
    }
}

#Preview {
    AnimatedToastExamples()
        .environmentObject(ToastManager())
}

#endif
