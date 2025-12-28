import SwiftUI
import FamilyControls

struct SettingsView: View {
    @EnvironmentObject var blockingStateManager: BlockingStateManager
    @EnvironmentObject var appBlockingManager: AppBlockingManager
    @Environment(\.dismiss) private var dismiss

    @State private var showingResetConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                // Status Section
                Section {
                    StatusRow(
                        title: "Blocking Status",
                        value: blockingStateManager.isBlocking ? "Active" : "Inactive",
                        color: blockingStateManager.isBlocking ? .red : .green
                    )

                    if blockingStateManager.isBlocking {
                        StatusRow(
                            title: "Blocking Duration",
                            value: blockingStateManager.formattedBlockingDuration,
                            color: .orange
                        )
                    }

                    StatusRow(
                        title: "Last Toggle",
                        value: blockingStateManager.lastToggleFormatted,
                        color: .blue
                    )
                } header: {
                    Text("Current Status")
                }

                // Selection Summary Section
                Section {
                    HStack {
                        Label("Apps Selected", systemImage: "app.fill")
                        Spacer()
                        Text("\(appBlockingManager.selectedApps.applicationTokens.count)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("Categories Selected", systemImage: "square.grid.2x2.fill")
                        Spacer()
                        Text("\(appBlockingManager.selectedApps.categoryTokens.count)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("Websites Selected", systemImage: "globe")
                        Spacer()
                        Text("\(appBlockingManager.selectedApps.webDomainTokens.count)")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Blocked Content")
                }

                // Screen Time Section
                Section {
                    Button(action: openScreenTimeSettings) {
                        Label("Open Screen Time Settings", systemImage: "hourglass")
                    }

                    Button(action: requestAuthorization) {
                        Label("Re-authorize Screen Time", systemImage: "checkmark.shield")
                    }
                } header: {
                    Text("Screen Time")
                } footer: {
                    Text("This app uses Screen Time to block apps. Make sure Screen Time is enabled in Settings.")
                }

                // NFC Section
                Section {
                    HStack {
                        Label("NFC Status", systemImage: "wave.3.right")
                        Spacer()
                        Text("Ready")
                            .foregroundColor(.green)
                    }
                } header: {
                    Text("NFC")
                } footer: {
                    Text("Any NFC chip can be used to toggle app blocking. Simply tap your iPhone on the chip.")
                }

                // Reset Section
                Section {
                    Button(action: { showingResetConfirmation = true }) {
                        Label("Reset All Settings", systemImage: "arrow.counterclockwise")
                            .foregroundColor(.red)
                    }
                } header: {
                    Text("Reset")
                } footer: {
                    Text("This will clear all selected apps, unblock everything, and reset the app to its initial state.")
                }

                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog(
                "Reset All Settings?",
                isPresented: $showingResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    resetAllSettings()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will clear all selected apps and unblock everything. This action cannot be undone.")
            }
        }
    }

    // MARK: - Actions

    private func openScreenTimeSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    private func requestAuthorization() {
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            } catch {
                print("Failed to request authorization: \(error)")
            }
        }
    }

    private func resetAllSettings() {
        appBlockingManager.clearSelection()
        blockingStateManager.setBlocking(false)
    }
}

// MARK: - Status Row
struct StatusRow: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(BlockingStateManager())
        .environmentObject(AppBlockingManager())
}
