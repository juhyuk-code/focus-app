import SwiftUI
import FamilyControls

struct ContentView: View {
    @EnvironmentObject var blockingStateManager: BlockingStateManager
    @EnvironmentObject var appBlockingManager: AppBlockingManager
    @StateObject private var nfcManager = NFCManager()

    @State private var showingAppSelection = false
    @State private var showingSettings = false
    @State private var animatePulse = false
    @State private var animateGlow = false

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: blockingStateManager.isBlocking
                    ? [Color(hex: "1a1a2e"), Color(hex: "16213e")]
                    : [Color(hex: "0f0f1a"), Color(hex: "1a1a2e")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Ambient glow effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            (blockingStateManager.isBlocking ? Color.red : Color.cyan).opacity(0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(y: -100)
                .blur(radius: 60)
                .scaleEffect(animateGlow ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animateGlow)

            VStack(spacing: 0) {
                // Header
                header
                    .padding(.top, 20)

                Spacer()

                // Main Status Card
                statusCard
                    .padding(.horizontal, 24)

                Spacer()

                // NFC Button
                nfcButton
                    .padding(.vertical, 30)

                Spacer()

                // Stats Row
                statsRow
                    .padding(.horizontal, 24)

                Spacer()

                // Bottom Buttons
                bottomButtons
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            animateGlow = true
        }
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

    // MARK: - Header
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("FOCUS")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Text("Stay in the zone")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            Button(action: { showingSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(12)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Status Card
    private var statusCard: some View {
        VStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: blockingStateManager.isBlocking
                                ? [Color.red.opacity(0.3), Color.red.opacity(0.1)]
                                : [Color.cyan.opacity(0.3), Color.cyan.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: blockingStateManager.isBlocking ? "lock.fill" : "lock.open.fill")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(blockingStateManager.isBlocking ? .red : .cyan)
                    .symbolEffect(.bounce, value: blockingStateManager.isBlocking)
            }

            // Status Text
            VStack(spacing: 8) {
                Text(blockingStateManager.isBlocking ? "FOCUS MODE" : "UNLOCKED")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(blockingStateManager.isBlocking ? "Apps are blocked" : "All apps accessible")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }

            // Duration (when blocking)
            if blockingStateManager.isBlocking {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                    Text(blockingStateManager.formattedBlockingDuration)
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                }
                .foregroundColor(.red.opacity(0.8))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.15))
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }

    // MARK: - NFC Button
    private var nfcButton: some View {
        Button(action: { nfcManager.startScanning() }) {
            ZStack {
                // Outer pulse rings
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 2)
                        .frame(width: 140 + CGFloat(i * 30), height: 140 + CGFloat(i * 30))
                        .scaleEffect(animatePulse ? 1.2 : 1.0)
                        .opacity(animatePulse ? 0 : 0.5)
                        .animation(
                            .easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                            .delay(Double(i) * 0.3),
                            value: animatePulse
                        )
                }

                // Main button
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "00d4ff"), Color(hex: "0099cc")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: Color.cyan.opacity(0.5), radius: 20, x: 0, y: 10)

                VStack(spacing: 6) {
                    Image(systemName: "wave.3.right")
                        .font(.system(size: 32, weight: .semibold))
                        .rotationEffect(.degrees(-45))

                    Text("TAP")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .onAppear { animatePulse = true }
    }

    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: 16) {
            StatCard(
                icon: "app.fill",
                value: "\(appBlockingManager.selectedApps.applicationTokens.count)",
                label: "APPS"
            )

            StatCard(
                icon: "square.grid.2x2.fill",
                value: "\(appBlockingManager.selectedApps.categoryTokens.count)",
                label: "CATEGORIES"
            )
        }
    }

    // MARK: - Bottom Buttons
    private var bottomButtons: some View {
        Button(action: { showingAppSelection = true }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                Text("Select Apps to Block")
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
        .disabled(blockingStateManager.isBlocking)
        .opacity(blockingStateManager.isBlocking ? 0.5 : 1)
    }

    // MARK: - Actions
    private func toggleBlocking() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            if blockingStateManager.isBlocking {
                appBlockingManager.unblockApps()
                blockingStateManager.setBlocking(false)
            } else {
                appBlockingManager.blockApps()
                blockingStateManager.setBlocking(true)
            }
        }

        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.cyan)

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.4))
                .kerning(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
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

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(BlockingStateManager())
        .environmentObject(AppBlockingManager())
}
