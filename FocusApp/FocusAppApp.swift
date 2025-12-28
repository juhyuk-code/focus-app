import SwiftUI
import FamilyControls

@main
struct FocusAppApp: App {
    @StateObject private var blockingStateManager = BlockingStateManager()
    @StateObject private var appBlockingManager = AppBlockingManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(blockingStateManager)
                .environmentObject(appBlockingManager)
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
