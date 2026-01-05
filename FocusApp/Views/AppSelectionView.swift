import SwiftUI
import FamilyControls

struct AppSelectionView: View {
    @EnvironmentObject var appBlockingManager: AppBlockingManager
    @Environment(\.dismiss) private var dismiss

    @State private var isPickerPresented = false

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
                // Custom Header
                header
                    .padding(.top, 20)
                    .padding(.bottom, 30)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Hero Section
                        heroSection

                        // Selection Summary
                        selectionSummary

                        // Action Buttons
                        actionButtons

                        // Info Section
                        infoSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(.dark)
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
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(10)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }

            Spacer()

            Text("SELECT APPS")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .kerning(2)

            Spacer()

            Button(action: {
                appBlockingManager.saveSelectedApps()
                dismiss()
            }) {
                Text("Done")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.cyan)
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "667eea").opacity(0.3), Color(hex: "764ba2").opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "apps.iphone")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(Color(hex: "667eea"))
            }

            VStack(spacing: 8) {
                Text("Choose Your Blocklist")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Select apps that will be blocked\nwhen Focus mode is active")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 20)
    }

    // MARK: - Selection Summary
    private var selectionSummary: some View {
        HStack(spacing: 12) {
            SelectionStatBox(
                value: appBlockingManager.selectedApps.applicationTokens.count,
                label: "APPS",
                color: Color.cyan
            )

            SelectionStatBox(
                value: appBlockingManager.selectedApps.categoryTokens.count,
                label: "CATEGORIES",
                color: Color(hex: "667eea")
            )

            SelectionStatBox(
                value: appBlockingManager.selectedApps.webDomainTokens.count,
                label: "WEBSITES",
                color: Color.orange
            )
        }
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Choose Apps Button
            Button(action: { isPickerPresented = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    Text("Choose Apps & Categories")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 15, x: 0, y: 8)
            }
            .buttonStyle(ScaleButtonStyle())

            // Clear Selection Button
            if appBlockingManager.hasSelectedApps {
                Button(action: { appBlockingManager.clearSelection() }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 16))
                        Text("Clear Selection")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.red.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }

    // MARK: - Info Section
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("How it works")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 12) {
                StepRow(number: 1, text: "Select apps and categories to block")
                StepRow(number: 2, text: "Tap your NFC chip to activate")
                StepRow(number: 3, text: "Tap again to unblock")
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Selection Stat Box
struct SelectionStatBox: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text("\(value)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.white.opacity(0.4))
                .kerning(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
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

// MARK: - Step Row
struct StepRow: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 24, height: 24)
                .background(Color.yellow)
                .clipShape(Circle())

            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

#Preview {
    AppSelectionView()
        .environmentObject(AppBlockingManager())
}
