import SwiftUI
import FamilyControls

struct AppSelectionView: View {
    @EnvironmentObject var appBlockingManager: AppBlockingManager
    @Environment(\.dismiss) private var dismiss

    @State private var isPickerPresented = false

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
                    VStack(spacing: 32) {
                        // Title Section
                        titleSection
                            .padding(.top, 40)

                        // Stats Grid
                        statsSection

                        // Action Button
                        actionSection

                        // Instructions
                        instructionsSection

                        // Clear Button
                        if appBlockingManager.hasSelectedApps {
                            clearSection
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(.light)
        .familyActivityPicker(
            isPresented: $isPickerPresented,
            selection: $appBlockingManager.selectedApps
        )
        .onChange(of: appBlockingManager.selectedApps) { _, _ in
            appBlockingManager.saveSelectedApps()
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Text("cancel")
                    .font(TE.font(14, weight: .medium))
                    .foregroundColor(TE.textSecondary)
            }

            Spacer()

            Text("select apps")
                .font(TE.font(14, weight: .medium))
                .foregroundColor(TE.text)

            Spacer()

            Button(action: {
                appBlockingManager.saveSelectedApps()
                dismiss()
            }) {
                Text("done")
                    .font(TE.font(14, weight: .medium))
                    .foregroundColor(TE.orange)
            }
        }
    }

    // MARK: - Title Section
    private var titleSection: some View {
        VStack(spacing: 12) {
            // Simple icon
            ZStack {
                Circle()
                    .stroke(TE.border, lineWidth: 1)
                    .frame(width: 80, height: 80)

                Rectangle()
                    .fill(TE.text)
                    .frame(width: 24, height: 24)
                    .cornerRadius(6)
            }

            VStack(spacing: 6) {
                Text("blocklist")
                    .font(TE.font(24, weight: .light))
                    .foregroundColor(TE.text)

                Text("choose apps to block during focus mode")
                    .font(TE.font(13, weight: .regular))
                    .foregroundColor(TE.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: 1) {
            TESelectionStat(value: appBlockingManager.selectedApps.applicationTokens.count, label: "apps")

            Rectangle()
                .fill(TE.border)
                .frame(width: 1)

            TESelectionStat(value: appBlockingManager.selectedApps.categoryTokens.count, label: "categories")

            Rectangle()
                .fill(TE.border)
                .frame(width: 1)

            TESelectionStat(value: appBlockingManager.selectedApps.webDomainTokens.count, label: "websites")
        }
        .background(TE.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(TE.border, lineWidth: 1)
        )
    }

    // MARK: - Action Section
    private var actionSection: some View {
        Button(action: { isPickerPresented = true }) {
            HStack {
                Circle()
                    .fill(TE.orange)
                    .frame(width: 8, height: 8)

                Text("choose apps & categories")
                    .font(TE.font(15, weight: .medium))

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(TE.text)
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(TE.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(TE.border, lineWidth: 1)
            )
        }
        .buttonStyle(TEButtonStyle())
    }

    // MARK: - Instructions Section
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("how it works")
                .font(TE.font(12, weight: .medium))
                .foregroundColor(TE.textSecondary)
                .kerning(0.5)

            VStack(alignment: .leading, spacing: 12) {
                TEStepRow(number: 1, text: "select apps and categories")
                TEStepRow(number: 2, text: "tap nfc chip to activate blocking")
                TEStepRow(number: 3, text: "tap again to unblock")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(TE.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(TE.border, lineWidth: 1)
        )
    }

    // MARK: - Clear Section
    private var clearSection: some View {
        Button(action: { appBlockingManager.clearSelection() }) {
            HStack {
                Text("clear selection")
                    .font(TE.font(14, weight: .medium))
                Spacer()
                Text("×")
                    .font(TE.font(18, weight: .light))
            }
            .foregroundColor(TE.red)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(TE.red.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(TEButtonStyle())
    }
}

// MARK: - TE Selection Stat
struct TESelectionStat: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Text("\(value)")
                .font(TE.mono(22, weight: .medium))
                .foregroundColor(TE.text)

            Text(label)
                .font(TE.font(11, weight: .regular))
                .foregroundColor(TE.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

// MARK: - TE Step Row
struct TEStepRow: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Text("\(number)")
                .font(TE.mono(12, weight: .medium))
                .foregroundColor(TE.textSecondary)
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(TE.border, lineWidth: 1)
                )

            Text(text)
                .font(TE.font(14, weight: .regular))
                .foregroundColor(TE.text)
        }
    }
}

#Preview {
    AppSelectionView()
        .environmentObject(AppBlockingManager())
}
