import SwiftUI
import FamilyControls

@main
struct FocusAppApp: App {
    @StateObject private var blockingStateManager = BlockingStateManager()
    @StateObject private var profileManager = ProfileManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if profileManager.hasCompletedOnboarding {
                    ContentView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(blockingStateManager)
            .environmentObject(profileManager)
            .onAppear {
                requestScreenTimeAuthorization()
            }
        }
    }

    private func requestScreenTimeAuthorization() {
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                print("Screen Time authorization granted")
            } catch {
                print("Failed to get Screen Time authorization: \(error)")
            }
        }
    }
}
