import SwiftUI
import FamilyControls
import CoreHaptics

// MARK: - Teenage Engineering Design System
struct TE {
    // Colors - Clean, minimal palette
    static let background = Color(hex: "FAFAFA")
    static let surface = Color.white
    static let text = Color(hex: "1A1A1A")
    static let textSecondary = Color(hex: "8A8A8A")
    static let border = Color(hex: "E5E5E5")
    static let orange = Color(hex: "FF5C00")  // TE signature orange
    static let green = Color(hex: "00D26A")
    static let red = Color(hex: "FF3B30")

    // Typography - Univers-inspired (SF Pro is similar)
    static func font(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static func mono(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

struct ContentView: View {
    @EnvironmentObject var blockingStateManager: BlockingStateManager
    @EnvironmentObject var appBlockingManager: AppBlockingManager
    @StateObject private var nfcManager = NFCManager()

    @State private var showingAppSelection = false
    @State private var showingSettings = false
    @State private var hapticEngine: CHHapticEngine?

    var body: some View {
        ZStack {
            // Clean background
            TE.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                header
                    .padding(.top, 16)
                    .padding(.horizontal, 24)

                Spacer()

                // Main Status Display
                statusDisplay

                Spacer()

                // NFC Button
                nfcButton

                Spacer()

                // Stats Grid
                statsGrid
                    .padding(.horizontal, 24)

                // Bottom Action
                bottomAction
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.light)
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
        .onAppear {
            prepareHaptics()
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("focus")
                    .font(TE.font(32, weight: .light))
                    .foregroundColor(TE.text)
                    .kerning(-0.5)

                Text("nfc app blocker")
                    .font(TE.font(12, weight: .regular))
                    .foregroundColor(TE.textSecondary)
                    .kerning(0.5)
            }

            Spacer()

            Button(action: { showingSettings = true }) {
                Text("settings")
                    .font(TE.font(13, weight: .medium))
                    .foregroundColor(TE.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(TE.border, lineWidth: 1)
                    )
            }
        }
    }

    // MARK: - Status Display
    private var statusDisplay: some View {
        VStack(spacing: 24) {
            // Status indicator circle
            ZStack {
                Circle()
                    .stroke(TE.border, lineWidth: 1)
                    .frame(width: 140, height: 140)

                Circle()
                    .fill(blockingStateManager.isBlocking ? TE.orange : TE.surface)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(blockingStateManager.isBlocking ? TE.orange : TE.border, lineWidth: 1)
                    )

                VStack(spacing: 4) {
                    Text(blockingStateManager.isBlocking ? "on" : "off")
                        .font(TE.mono(28, weight: .medium))
                        .foregroundColor(blockingStateManager.isBlocking ? .white : TE.text)
                }
            }

            // Status text
            VStack(spacing: 8) {
                Text(blockingStateManager.isBlocking ? "focus mode active" : "apps unlocked")
                    .font(TE.font(16, weight: .medium))
                    .foregroundColor(TE.text)

                if blockingStateManager.isBlocking {
                    Text(blockingStateManager.formattedBlockingDuration)
                        .font(TE.mono(14, weight: .regular))
                        .foregroundColor(TE.orange)
                } else {
                    Text("tap nfc to block apps")
                        .font(TE.font(14, weight: .regular))
                        .foregroundColor(TE.textSecondary)
                }
            }
        }
    }

    // MARK: - NFC Button
    private var nfcButton: some View {
        Button(action: {
            // Haptic feedback - use notification style for pronounced feel
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)

            // Small delay so haptic completes before NFC dialog appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                nfcManager.startScanning()
            }
        }) {
            VStack(spacing: 16) {
                // NFC Icon - minimal line art style
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(TE.border, lineWidth: 1)
                        .frame(width: 100, height: 100)

                    // Inner ring
                    Circle()
                        .stroke(TE.text.opacity(0.2), lineWidth: 1)
                        .frame(width: 70, height: 70)

                    // Center dot
                    Circle()
                        .fill(TE.orange)
                        .frame(width: 40, height: 40)

                    // NFC waves
                    ForEach(0..<3, id: \.self) { i in
                        Arc(startAngle: .degrees(-30), endAngle: .degrees(30))
                            .stroke(TE.text, lineWidth: 1.5)
                            .frame(width: CGFloat(55 + i * 15), height: CGFloat(55 + i * 15))
                    }
                }

                Text("scan nfc")
                    .font(TE.font(13, weight: .medium))
                    .foregroundColor(TE.textSecondary)
            }
        }
        .buttonStyle(TEButtonStyle())
    }

    // MARK: - Stats Grid
    private var statsGrid: some View {
        HStack(spacing: 12) {
            TEStatBox(
                label: "apps",
                value: appBlockingManager.selectedApps.applicationTokens.count
            )

            TEStatBox(
                label: "categories",
                value: appBlockingManager.selectedApps.categoryTokens.count
            )

            TEStatBox(
                label: "websites",
                value: appBlockingManager.selectedApps.webDomainTokens.count
            )
        }
    }

    // MARK: - Bottom Action
    private var bottomAction: some View {
        Button(action: { showingAppSelection = true }) {
            HStack {
                Text("select apps to block")
                    .font(TE.font(15, weight: .medium))

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(TE.text)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(TE.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(TE.border, lineWidth: 1)
            )
        }
        .buttonStyle(TEButtonStyle())
        .disabled(blockingStateManager.isBlocking)
        .opacity(blockingStateManager.isBlocking ? 0.4 : 1)
    }

    // MARK: - Actions
    private func toggleBlocking() {
        withAnimation(.easeInOut(duration: 0.2)) {
            if blockingStateManager.isBlocking {
                appBlockingManager.unblockApps()
                blockingStateManager.setBlocking(false)
            } else {
                appBlockingManager.blockApps()
                blockingStateManager.setBlocking(true)
            }
        }

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    // MARK: - Haptics
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()

            // Handle engine reset
            hapticEngine?.resetHandler = { [self] in
                do {
                    try hapticEngine?.start()
                } catch {
                    print("Failed to restart haptic engine: \(error)")
                }
            }
        } catch {
            print("Failed to create haptic engine: \(error)")
        }
    }

    private func playNFCButtonHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            // Fallback to simple haptic
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            return
        }

        // Create engine if it doesn't exist
        if hapticEngine == nil {
            do {
                hapticEngine = try CHHapticEngine()
            } catch {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                return
            }
        }

        // Ensure engine is started (it may have stopped)
        do {
            try hapticEngine?.start()
        } catch {
            // Engine failed to start, use fallback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            return
        }

        // Create a pronounced but not too long haptic pattern
        // Sharp initial hit + brief sustain for that "meaty" feel
        var events: [CHHapticEvent] = []

        // Initial sharp transient - gives immediate tactile response
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9)
        let transient = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensity, sharpness],
            relativeTime: 0
        )
        events.append(transient)

        // Brief continuous sustain - extends the feel without being too long
        let sustainIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
        let sustainSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
        let continuous = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [sustainIntensity, sustainSharpness],
            relativeTime: 0.02,
            duration: 0.12
        )
        events.append(continuous)

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play haptic: \(error)")
            // Fallback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
}

// MARK: - Arc Shape for NFC waves
struct Arc: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        return path
    }
}

// MARK: - TE Stat Box
struct TEStatBox: View {
    let label: String
    let value: Int

    var body: some View {
        VStack(spacing: 8) {
            Text("\(value)")
                .font(TE.mono(24, weight: .medium))
                .foregroundColor(TE.text)

            Text(label)
                .font(TE.font(11, weight: .regular))
                .foregroundColor(TE.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(TE.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(TE.border, lineWidth: 1)
        )
    }
}

// MARK: - TE Button Style
struct TEButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
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
