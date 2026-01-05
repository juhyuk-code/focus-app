import SwiftUI
import FamilyControls

struct SettingsView: View {
    @EnvironmentObject var blockingStateManager: BlockingStateManager
    @EnvironmentObject var appBlockingManager: AppBlockingManager
    @Environment(\.dismiss) private var dismiss

    @State private var showingResetConfirmation = false

    var body: some View {
        ZStack {
            // Clean background
            TE.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                header
                    .padding(.top, 16)
                    .padding(.horizontal, 24)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Status Section
                        statusSection

                        // Stats Section
                        statsSection

                        // Actions Section
                        actionsSection

                        // Reset Section
                        resetSection

                        // Info Section
                        infoSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    .padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(.light)
        .confirmationDialog(
            "reset everything?",
            isPresented: $showingResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("reset", role: .destructive) {
                resetAllSettings()
            }
            Button("cancel", role: .cancel) {}
        } message: {
            Text("this will clear all selected apps and unblock everything.")
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Text("close")
                    .font(TE.font(14, weight: .medium))
                    .foregroundColor(TE.textSecondary)
            }

            Spacer()

            Text("settings")
                .font(TE.font(14, weight: .medium))
                .foregroundColor(TE.text)

            Spacer()

            // Balance spacer
            Text("close")
                .font(TE.font(14, weight: .medium))
                .foregroundColor(.clear)
        }
    }

    // MARK: - Status Section
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("status")
                .font(TE.font(12, weight: .medium))
                .foregroundColor(TE.textSecondary)
                .kerning(0.5)

            VStack(spacing: 0) {
                TESettingsRow(
                    label: "focus mode",
                    value: blockingStateManager.isBlocking ? "on" : "off",
                    valueColor: blockingStateManager.isBlocking ? TE.orange : TE.green,
                    showIndicator: true,
                    indicatorColor: blockingStateManager.isBlocking ? TE.orange : TE.green
                )

                if blockingStateManager.isBlocking {
                    Rectangle().fill(TE.border).frame(height: 1)

                    TESettingsRow(
                        label: "duration",
                        value: blockingStateManager.formattedBlockingDuration,
                        valueColor: TE.orange
                    )
                }

                Rectangle().fill(TE.border).frame(height: 1)

                TESettingsRow(
                    label: "last toggle",
                    value: blockingStateManager.lastToggleFormatted,
                    valueColor: TE.textSecondary
                )
            }
            .background(TE.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(TE.border, lineWidth: 1)
            )
        }
    }

    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("blocked content")
                .font(TE.font(12, weight: .medium))
                .foregroundColor(TE.textSecondary)
                .kerning(0.5)

            HStack(spacing: 1) {
                TEMiniStat(
                    value: appBlockingManager.selectedApps.applicationTokens.count,
                    label: "apps"
                )

                Rectangle().fill(TE.border).frame(width: 1)

                TEMiniStat(
                    value: appBlockingManager.selectedApps.categoryTokens.count,
                    label: "categories"
                )

                Rectangle().fill(TE.border).frame(width: 1)

                TEMiniStat(
                    value: appBlockingManager.selectedApps.webDomainTokens.count,
                    label: "websites"
                )
            }
            .background(TE.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(TE.border, lineWidth: 1)
            )
        }
    }

    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("actions")
                .font(TE.font(12, weight: .medium))
                .foregroundColor(TE.textSecondary)
                .kerning(0.5)

            VStack(spacing: 8) {
                TEActionRow(label: "screen time settings", action: openScreenTimeSettings)
                TEActionRow(label: "re-authorize permissions", action: requestAuthorization)
            }
        }
    }

    // MARK: - Reset Section
    private var resetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("danger zone")
                .font(TE.font(12, weight: .medium))
                .foregroundColor(TE.red.opacity(0.8))
                .kerning(0.5)

            Button(action: { showingResetConfirmation = true }) {
                HStack {
                    Text("reset all settings")
                        .font(TE.font(14, weight: .medium))
                    Spacer()
                    Text("×")
                        .font(TE.font(18, weight: .light))
                }
                .foregroundColor(TE.red)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(TE.red.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(TEButtonStyle())
        }
    }

    // MARK: - Info Section
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("about")
                .font(TE.font(12, weight: .medium))
                .foregroundColor(TE.textSecondary)
                .kerning(0.5)

            VStack(spacing: 0) {
                TEInfoRow(label: "version", value: "1.0.0")
                Rectangle().fill(TE.border).frame(height: 1)
                TEInfoRow(label: "build", value: "1")
                Rectangle().fill(TE.border).frame(height: 1)
                TEInfoRow(label: "nfc", value: "ready", valueColor: TE.green)
            }
            .background(TE.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(TE.border, lineWidth: 1)
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

// MARK: - TE Settings Row
struct TESettingsRow: View {
    let label: String
    let value: String
    var valueColor: Color = TE.text
    var showIndicator: Bool = false
    var indicatorColor: Color = TE.orange

    var body: some View {
        HStack {
            if showIndicator {
                Circle()
                    .fill(indicatorColor)
                    .frame(width: 6, height: 6)
            }

            Text(label)
                .font(TE.font(14, weight: .regular))
                .foregroundColor(TE.text)

            Spacer()

            Text(value)
                .font(TE.mono(14, weight: .medium))
                .foregroundColor(valueColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - TE Mini Stat
struct TEMiniStat: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(TE.mono(20, weight: .medium))
                .foregroundColor(TE.text)

            Text(label)
                .font(TE.font(10, weight: .regular))
                .foregroundColor(TE.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
}

// MARK: - TE Action Row
struct TEActionRow: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(TE.font(14, weight: .medium))
                    .foregroundColor(TE.text)

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(TE.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(TE.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(TE.border, lineWidth: 1)
            )
        }
        .buttonStyle(TEButtonStyle())
    }
}

// MARK: - TE Info Row
struct TEInfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = TE.textSecondary

    var body: some View {
        HStack {
            Text(label)
                .font(TE.font(13, weight: .regular))
                .foregroundColor(TE.textSecondary)

            Spacer()

            Text(value)
                .font(TE.mono(13, weight: .medium))
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
