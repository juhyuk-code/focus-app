import SwiftUI
import FamilyControls

struct SettingsView: View {
    @EnvironmentObject var blockingStateManager: BlockingStateManager
    @EnvironmentObject var appBlockingManager: AppBlockingManager
    @Environment(\.dismiss) private var dismiss

    @State private var showingResetConfirmation = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "0f0f1a"), Color(hex: "1a1a2e")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                header
                    .padding(.top, 20)
                    .padding(.bottom, 30)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Status Section
                        statusSection

                        // Blocked Content Section
                        blockedContentSection

                        // Quick Actions
                        quickActionsSection

                        // Danger Zone
                        dangerZoneSection

                        // About Section
                        aboutSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(.dark)
        .confirmationDialog(
            "Reset Everything?",
            isPresented: $showingResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset", role: .destructive) {
                resetAllSettings()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will clear all selected apps and unblock everything.")
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(10)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }

            Spacer()

            Text("SETTINGS")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .kerning(2)

            Spacer()

            // Invisible spacer for balance
            Circle()
                .fill(Color.clear)
                .frame(width: 36, height: 36)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Status Section
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "STATUS", icon: "chart.bar.fill")

            VStack(spacing: 12) {
                SettingsRow(
                    icon: "lock.fill",
                    iconColor: blockingStateManager.isBlocking ? .red : .green,
                    title: "Focus Mode",
                    value: blockingStateManager.isBlocking ? "Active" : "Inactive",
                    valueColor: blockingStateManager.isBlocking ? .red : .green
                )

                if blockingStateManager.isBlocking {
                    SettingsRow(
                        icon: "clock.fill",
                        iconColor: .orange,
                        title: "Duration",
                        value: blockingStateManager.formattedBlockingDuration,
                        valueColor: .orange
                    )
                }

                SettingsRow(
                    icon: "arrow.triangle.2.circlepath",
                    iconColor: .cyan,
                    title: "Last Toggle",
                    value: blockingStateManager.lastToggleFormatted,
                    valueColor: .white.opacity(0.6)
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Blocked Content Section
    private var blockedContentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "BLOCKED CONTENT", icon: "square.stack.fill")

            HStack(spacing: 12) {
                MiniStatCard(
                    value: appBlockingManager.selectedApps.applicationTokens.count,
                    label: "Apps",
                    icon: "app.fill",
                    color: .cyan
                )

                MiniStatCard(
                    value: appBlockingManager.selectedApps.categoryTokens.count,
                    label: "Categories",
                    icon: "square.grid.2x2.fill",
                    color: Color(hex: "667eea")
                )

                MiniStatCard(
                    value: appBlockingManager.selectedApps.webDomainTokens.count,
                    label: "Sites",
                    icon: "globe",
                    color: .orange
                )
            }
        }
    }

    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "QUICK ACTIONS", icon: "bolt.fill")

            VStack(spacing: 10) {
                ActionButton(
                    icon: "hourglass",
                    title: "Screen Time Settings",
                    subtitle: "Open system settings",
                    color: Color(hex: "667eea")
                ) {
                    openScreenTimeSettings()
                }

                ActionButton(
                    icon: "checkmark.shield.fill",
                    title: "Re-authorize",
                    subtitle: "Refresh permissions",
                    color: .green
                ) {
                    requestAuthorization()
                }
            }
        }
    }

    // MARK: - Danger Zone Section
    private var dangerZoneSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "DANGER ZONE", icon: "exclamationmark.triangle.fill", color: .red)

            Button(action: { showingResetConfirmation = true }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 18))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Reset All Settings")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Clear selection and unblock all")
                            .font(.system(size: 12))
                            .foregroundColor(.red.opacity(0.6))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.red.opacity(0.5))
                }
                .foregroundColor(.red)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }

    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "ABOUT", icon: "info.circle.fill")

            VStack(spacing: 0) {
                AboutRow(title: "Version", value: "1.0.0")
                Divider().background(Color.white.opacity(0.1))
                AboutRow(title: "Build", value: "1")
                Divider().background(Color.white.opacity(0.1))
                AboutRow(title: "NFC Status", value: "Ready", valueColor: .green)
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
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

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String
    var color: Color = .white

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color.opacity(0.6))
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color.opacity(0.6))
                .kerning(1.5)
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    var valueColor: Color = .white

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.8))

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(valueColor)
        }
    }
}

// MARK: - Mini Stat Card
struct MiniStatCard: View {
    let value: Int
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)

            Text("\(value)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - About Row
struct AboutRow: View {
    let title: String
    let value: String
    var valueColor: Color = .white.opacity(0.6)

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(valueColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    SettingsView()
        .environmentObject(BlockingStateManager())
        .environmentObject(AppBlockingManager())
}
