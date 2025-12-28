import SwiftUI
import FamilyControls

struct ContentView: View {
    @EnvironmentObject var blockingStateManager: BlockingStateManager
    @EnvironmentObject var appBlockingManager: AppBlockingManager
    @StateObject private var nfcManager = NFCManager()

    @State private var showingAppSelection = false
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Status Card
                StatusCard(isBlocking: blockingStateManager.isBlocking)

                // NFC Tap Button
                NFCTapButton(nfcManager: nfcManager) {
                    handleNFCTap()
                }

                // Selected Apps Summary
                SelectedAppsSummary(
                    appCount: appBlockingManager.selectedApps.applicationTokens.count,
                    categoryCount: appBlockingManager.selectedApps.categoryTokens.count
                )

                Spacer()

                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: { showingAppSelection = true }) {
                        Label("Select Apps to Block", systemImage: "apps.iphone")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(blockingStateManager.isBlocking ? Color.gray.opacity(0.3) : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(blockingStateManager.isBlocking)

                    Button(action: { showingSettings = true }) {
                        Label("Settings", systemImage: "gear")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Focus App")
            .sheet(isPresented: $showingAppSelection) {
                AppSelectionView()
                    .environmentObject(appBlockingManager)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(blockingStateManager)
                    .environmentObject(appBlockingManager)
            }
            .onReceive(nfcManager.$lastScannedTag) { tag in
                if tag != nil {
                    toggleBlocking()
                }
            }
        }
    }

    private func handleNFCTap() {
        nfcManager.startScanning()
    }

    private func toggleBlocking() {
        if blockingStateManager.isBlocking {
            // Unblock apps
            appBlockingManager.unblockApps()
            blockingStateManager.setBlocking(false)
        } else {
            // Block apps
            appBlockingManager.blockApps()
            blockingStateManager.setBlocking(true)
        }

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(blockingStateManager.isBlocking ? .warning : .success)
    }
}

// MARK: - Status Card
struct StatusCard: View {
    let isBlocking: Bool

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: isBlocking ? "lock.shield.fill" : "lock.open.fill")
                .font(.system(size: 60))
                .foregroundColor(isBlocking ? .red : .green)
                .symbolEffect(.bounce, value: isBlocking)

            Text(isBlocking ? "Apps Blocked" : "Apps Unlocked")
                .font(.title2)
                .fontWeight(.semibold)

            Text(isBlocking ? "Tap NFC chip to unblock" : "Tap NFC chip to block")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isBlocking ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isBlocking ? Color.red.opacity(0.3) : Color.green.opacity(0.3), lineWidth: 2)
        )
    }
}

// MARK: - NFC Tap Button
struct NFCTapButton: View {
    @ObservedObject var nfcManager: NFCManager
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 100, height: 100)

                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 80, height: 80)

                    Image(systemName: "wave.3.right")
                        .font(.system(size: 35))
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(-45))
                }

                Text(nfcManager.isScanning ? "Scanning..." : "Tap to Scan NFC")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
        }
        .disabled(nfcManager.isScanning)
    }
}

// MARK: - Selected Apps Summary
struct SelectedAppsSummary: View {
    let appCount: Int
    let categoryCount: Int

    var body: some View {
        HStack(spacing: 20) {
            SummaryItem(count: appCount, label: "Apps", icon: "app.fill")

            Divider()
                .frame(height: 40)

            SummaryItem(count: categoryCount, label: "Categories", icon: "square.grid.2x2.fill")
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SummaryItem: View {
    let count: Int
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text("\(count)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(BlockingStateManager())
        .environmentObject(AppBlockingManager())
}
