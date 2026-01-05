import SwiftUI
import FamilyControls

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
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var blockingStateManager: BlockingStateManager
    @StateObject private var nfcManager = NFCManager()

    @State private var selectedProfile: Profile?
    @State private var showingNFCScan = false
    @State private var showingProfileEditor = false
    @State private var profileToEdit: Profile?
    @State private var showingNewProfile = false
    @State private var editMode: EditMode = .inactive
    @State private var showingDeleteConfirmation = false
    @State private var profileToDelete: Profile?

    var body: some View {
        ZStack {
            TE.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.top, 16)
                    .padding(.horizontal, 24)

                // Status bar
                if profileManager.isBlocking, let active = profileManager.activeProfile {
                    activeStatusBar(profile: active)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                }

                // Profile list
                profileList
                    .padding(.top, 24)

                Spacer()

                // Add profile button
                addProfileButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.light)
        .sheet(isPresented: $showingNFCScan) {
            NFCScanModal(profile: selectedProfile, nfcManager: nfcManager) {
                // On successful scan
                if let profile = selectedProfile {
                    if profileManager.isBlocking {
                        profileManager.deactivateProfile()
                        blockingStateManager.setBlocking(false)
                    } else {
                        profileManager.activateProfile(profile)
                        blockingStateManager.setBlocking(true)
                    }
                }
                showingNFCScan = false
            }
        }
        .sheet(isPresented: $showingProfileEditor) {
            if let profile = profileToEdit {
                ProfileEditorView(profile: profile, isNew: false)
                    .environmentObject(profileManager)
            }
        }
        .sheet(isPresented: $showingNewProfile) {
            ProfileEditorView(profile: Profile(name: "", order: profileManager.profiles.count), isNew: true)
                .environmentObject(profileManager)
        }
        .onReceive(nfcManager.$lastScannedTag) { tag in
            if tag != nil && showingNFCScan {
                // NFC scanned successfully - the modal will handle the callback
            }
        }
        .alert("delete profile?", isPresented: $showingDeleteConfirmation) {
            Button("cancel", role: .cancel) {
                profileToDelete = nil
            }
            Button("delete", role: .destructive) {
                if let profile = profileToDelete {
                    profileManager.deleteProfile(profile)
                }
                profileToDelete = nil
            }
        } message: {
            Text("all settings for this profile will be permanently lost.")
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

            Button(action: { editMode = editMode == .active ? .inactive : .active }) {
                Text(editMode == .active ? "done" : "edit")
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

    // MARK: - Active Status Bar
    private func activeStatusBar(profile: Profile) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(TE.orange)
                .frame(width: 8, height: 8)

            Text("blocking: \(profile.name)")
                .font(TE.font(13, weight: .medium))
                .foregroundColor(TE.text)

            Spacer()

            Text(blockingStateManager.formattedBlockingDuration)
                .font(TE.mono(13, weight: .regular))
                .foregroundColor(TE.orange)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(TE.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(TE.orange, lineWidth: 1)
        )
    }

    // MARK: - Profile List
    private var profileList: some View {
        List {
            ForEach(profileManager.profiles) { profile in
                ProfileRow(
                    profile: profile,
                    isActive: profileManager.activeProfile?.id == profile.id,
                    onTap: {
                        selectedProfile = profile
                        showingNFCScan = true
                    }
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 24, bottom: 6, trailing: 24))
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        profileToDelete = profile
                        showingDeleteConfirmation = true
                    } label: {
                        Label("delete", systemImage: "trash")
                    }

                    Button {
                        profileToEdit = profile
                        showingProfileEditor = true
                    } label: {
                        Label("edit", systemImage: "pencil")
                    }
                    .tint(TE.orange)
                }
            }
            .onMove { source, destination in
                profileManager.moveProfile(from: source, to: destination)
            }
        }
        .listStyle(.plain)
        .environment(\.editMode, $editMode)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Add Profile Button
    private var addProfileButton: some View {
        Button(action: { showingNewProfile = true }) {
            HStack {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .medium))

                Text("new profile")
                    .font(TE.font(15, weight: .medium))
            }
            .foregroundColor(TE.text)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(TE.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(TE.border, lineWidth: 1)
            )
        }
        .buttonStyle(TEButtonStyle())
    }
}

// MARK: - Profile Row
struct ProfileRow: View {
    let profile: Profile
    let isActive: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isActive ? TE.orange : TE.surface)
                        .frame(width: 44, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(isActive ? TE.orange : TE.border, lineWidth: 1)
                        )

                    Image(systemName: profile.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isActive ? .white : TE.text)
                }

                // Name and info
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.name)
                        .font(TE.font(15, weight: .medium))
                        .foregroundColor(TE.text)

                    Text(profileSubtitle)
                        .font(TE.font(12, weight: .regular))
                        .foregroundColor(TE.textSecondary)
                }

                Spacer()

                // Arrow or active indicator
                if isActive {
                    Text("active")
                        .font(TE.font(11, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(TE.orange)
                        .cornerRadius(2)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(TE.textSecondary)
                }
            }
            .padding(16)
            .background(TE.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isActive ? TE.orange : TE.border, lineWidth: 1)
            )
        }
        .buttonStyle(TEButtonStyle())
    }

    private var profileSubtitle: String {
        let appCount = profile.selectedApps.applicationTokens.count
        let catCount = profile.selectedApps.categoryTokens.count

        if profile.isDefault && appCount == 0 && catCount == 0 {
            switch profile.name {
            case "highest screen time":
                return "top 10 most used apps"
            case "are you not entertained":
                return "entertainment & social media"
            case "monk mode":
                return "everything except essentials"
            default:
                return "tap to configure"
            }
        }

        if appCount == 0 && catCount == 0 {
            return "no apps selected"
        }

        var parts: [String] = []
        if appCount > 0 { parts.append("\(appCount) apps") }
        if catCount > 0 { parts.append("\(catCount) categories") }
        return parts.joined(separator: ", ")
    }
}

// MARK: - NFC Scan Modal
struct NFCScanModal: View {
    let profile: Profile?
    @ObservedObject var nfcManager: NFCManager
    let onSuccess: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var isScanning = false

    var body: some View {
        ZStack {
            TE.background.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // NFC Icon
                ZStack {
                    Circle()
                        .stroke(TE.border, lineWidth: 1)
                        .frame(width: 140, height: 140)

                    Circle()
                        .stroke(TE.text.opacity(0.2), lineWidth: 1)
                        .frame(width: 100, height: 100)

                    Circle()
                        .fill(TE.orange)
                        .frame(width: 60, height: 60)

                    // NFC waves
                    ForEach(0..<3, id: \.self) { i in
                        Arc(startAngle: .degrees(-30), endAngle: .degrees(30))
                            .stroke(TE.text, lineWidth: 1.5)
                            .frame(width: CGFloat(75 + i * 20), height: CGFloat(75 + i * 20))
                            .opacity(isScanning ? 1 : 0.3)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(i) * 0.2),
                                value: isScanning
                            )
                    }
                }

                VStack(spacing: 12) {
                    if let profile = profile {
                        Text(profile.name)
                            .font(TE.font(20, weight: .medium))
                            .foregroundColor(TE.text)
                    }

                    Text(isScanning ? "hold near nfc tag" : "tap to scan")
                        .font(TE.font(14, weight: .regular))
                        .foregroundColor(TE.textSecondary)
                }

                Spacer()

                // Scan button
                Button(action: startScan) {
                    Text(isScanning ? "scanning..." : "scan nfc")
                        .font(TE.font(15, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(TE.orange)
                        .cornerRadius(4)
                }
                .buttonStyle(TEButtonStyle())
                .disabled(isScanning)
                .padding(.horizontal, 24)

                // Cancel button
                Button(action: { dismiss() }) {
                    Text("cancel")
                        .font(TE.font(15, weight: .medium))
                        .foregroundColor(TE.textSecondary)
                }
                .padding(.bottom, 40)
            }
        }
        .onReceive(nfcManager.$lastScannedTag) { tag in
            if tag != nil && isScanning {
                isScanning = false
                onSuccess()
            }
        }
    }

    private func startScan() {
        isScanning = true
        nfcManager.startScanning()
    }
}

// MARK: - Profile Editor View
struct ProfileEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var profileManager: ProfileManager

    @State var profile: Profile
    let isNew: Bool

    @State private var showingAppSelection = false
    @State private var categoriesExpanded = true
    @State private var appsExpanded = true

    var body: some View {
        NavigationView {
            ZStack {
                TE.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Name field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("name")
                                .font(TE.font(12, weight: .medium))
                                .foregroundColor(TE.textSecondary)

                            TextField("profile name", text: $profile.name)
                                .font(TE.font(16, weight: .regular))
                                .foregroundColor(TE.text)
                                .padding(16)
                                .background(TE.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(TE.border, lineWidth: 1)
                                )
                                .textInputAutocapitalization(.never)
                        }

                        // Icon selector
                        VStack(alignment: .leading, spacing: 8) {
                            Text("icon")
                                .font(TE.font(12, weight: .medium))
                                .foregroundColor(TE.textSecondary)

                            IconPicker(selectedIcon: $profile.icon)
                        }

                        // Add/Edit apps button
                        VStack(alignment: .leading, spacing: 8) {
                            Text("blocked items")
                                .font(TE.font(12, weight: .medium))
                                .foregroundColor(TE.textSecondary)

                            Button(action: { showingAppSelection = true }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(TE.orange)

                                    Text("add or remove apps")
                                        .font(TE.font(15, weight: .medium))
                                        .foregroundColor(TE.text)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(TE.textSecondary)
                                }
                                .padding(16)
                                .background(TE.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(TE.border, lineWidth: 1)
                                )
                            }
                            .buttonStyle(TEButtonStyle())
                        }

                        // Categories section (expandable)
                        if !profile.selectedApps.categoryTokens.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                Button(action: { withAnimation { categoriesExpanded.toggle() } }) {
                                    HStack {
                                        Image(systemName: categoriesExpanded ? "chevron.down" : "chevron.right")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(TE.textSecondary)
                                            .frame(width: 20)

                                        Text("categories")
                                            .font(TE.font(14, weight: .medium))
                                            .foregroundColor(TE.text)

                                        Spacer()

                                        Text("\(profile.selectedApps.categoryTokens.count)")
                                            .font(TE.mono(13, weight: .medium))
                                            .foregroundColor(TE.orange)
                                    }
                                    .padding(16)
                                    .background(TE.surface)
                                }
                                .buttonStyle(TEButtonStyle())

                                if categoriesExpanded {
                                    VStack(spacing: 0) {
                                        ForEach(Array(profile.selectedApps.categoryTokens), id: \.hashValue) { token in
                                            HStack {
                                                Label(token)
                                                    .labelStyle(.iconOnly)
                                                    .font(.system(size: 24))

                                                Label(token)
                                                    .labelStyle(.titleOnly)
                                                    .font(TE.font(14, weight: .regular))
                                                    .foregroundColor(TE.text)

                                                Spacer()
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .background(TE.background)
                                        }
                                    }
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(TE.border, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        }

                        // Apps section (expandable)
                        if !profile.selectedApps.applicationTokens.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                Button(action: { withAnimation { appsExpanded.toggle() } }) {
                                    HStack {
                                        Image(systemName: appsExpanded ? "chevron.down" : "chevron.right")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(TE.textSecondary)
                                            .frame(width: 20)

                                        Text("apps")
                                            .font(TE.font(14, weight: .medium))
                                            .foregroundColor(TE.text)

                                        Spacer()

                                        Text("\(profile.selectedApps.applicationTokens.count)")
                                            .font(TE.mono(13, weight: .medium))
                                            .foregroundColor(TE.orange)
                                    }
                                    .padding(16)
                                    .background(TE.surface)
                                }
                                .buttonStyle(TEButtonStyle())

                                if appsExpanded {
                                    VStack(spacing: 0) {
                                        ForEach(Array(profile.selectedApps.applicationTokens), id: \.hashValue) { token in
                                            HStack {
                                                Label(token)
                                                    .labelStyle(.iconOnly)
                                                    .font(.system(size: 24))

                                                Label(token)
                                                    .labelStyle(.titleOnly)
                                                    .font(TE.font(14, weight: .regular))
                                                    .foregroundColor(TE.text)

                                                Spacer()
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .background(TE.background)
                                        }
                                    }
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(TE.border, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        }

                        // Empty state
                        if profile.selectedApps.categoryTokens.isEmpty && profile.selectedApps.applicationTokens.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "app.badge")
                                    .font(.system(size: 32))
                                    .foregroundColor(TE.textSecondary)

                                Text("no apps selected")
                                    .font(TE.font(14, weight: .regular))
                                    .foregroundColor(TE.textSecondary)

                                Text("tap 'add or remove apps' to select apps and categories to block")
                                    .font(TE.font(12, weight: .regular))
                                    .foregroundColor(TE.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(32)
                            .frame(maxWidth: .infinity)
                            .background(TE.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(TE.border, lineWidth: 1)
                            )
                        }

                        Spacer()
                    }
                    .padding(24)
                }
            }
            .navigationTitle(isNew ? "new profile" : "edit profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") { dismiss() }
                        .foregroundColor(TE.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        saveProfile()
                        dismiss()
                    }
                    .foregroundColor(TE.orange)
                    .disabled(profile.name.isEmpty)
                }
            }
            .familyActivityPicker(isPresented: $showingAppSelection, selection: $profile.selectedApps)
        }
    }

    private func saveProfile() {
        if isNew {
            profileManager.addProfile(profile)
        } else {
            profileManager.updateProfile(profile)
        }
    }
}

// MARK: - Icon Picker
struct IconPicker: View {
    @Binding var selectedIcon: String

    let icons = [
        "app.badge", "moon.fill", "tv.fill", "chart.bar.fill",
        "gamecontroller.fill", "bubble.left.fill", "camera.fill", "cart.fill",
        "book.fill", "music.note", "film.fill", "newspaper.fill",
        "heart.fill", "star.fill", "bolt.fill", "leaf.fill"
    ]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 8), spacing: 12) {
            ForEach(icons, id: \.self) { icon in
                Button(action: { selectedIcon = icon }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(selectedIcon == icon ? TE.orange : TE.surface)
                            .frame(height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(selectedIcon == icon ? TE.orange : TE.border, lineWidth: 1)
                            )

                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(selectedIcon == icon ? .white : TE.text)
                    }
                }
                .buttonStyle(TEButtonStyle())
            }
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
        .environmentObject(ProfileManager())
        .environmentObject(BlockingStateManager())
}
