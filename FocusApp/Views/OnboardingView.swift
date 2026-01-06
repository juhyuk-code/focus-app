import SwiftUI
import FamilyControls

struct OnboardingView: View {
    @EnvironmentObject var profileManager: ProfileManager

    @State private var currentStep = 0
    @State private var profileName = ""
    @State private var selectedIcon = "app.badge"
    @State private var selectedApps = FamilyActivitySelection()
    @State private var showingAppPicker = false

    var body: some View {
        ZStack {
            TE.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress indicator
                progressIndicator
                    .padding(.top, 60)
                    .padding(.horizontal, 24)

                Spacer()

                // Content based on current step
                switch currentStep {
                case 0:
                    welcomeStep
                case 1:
                    nameStep
                case 2:
                    appsStep
                case 3:
                    doneStep
                default:
                    EmptyView()
                }

                Spacer()

                // Navigation buttons
                navigationButtons
                    .padding(.horizontal, 24)
                    .padding(.bottom, 50)
            }
        }
        .familyActivityPicker(isPresented: $showingAppPicker, selection: $selectedApps)
    }

    // MARK: - Progress Indicator
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { step in
                RoundedRectangle(cornerRadius: 2)
                    .fill(step <= currentStep ? TE.orange : TE.border)
                    .frame(height: 4)
            }
        }
    }

    // MARK: - Step 1: Welcome
    private var welcomeStep: some View {
        VStack(spacing: 32) {
            // Icon
            ZStack {
                Circle()
                    .stroke(TE.border, lineWidth: 1)
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(TE.orange)
                    .frame(width: 80, height: 80)

                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            }

            VStack(spacing: 16) {
                Text("welcome to focus")
                    .font(TE.font(28, weight: .light))
                    .foregroundColor(TE.text)

                Text("block distracting apps with a simple nfc tap. create profiles for different focus modes and take control of your screen time.")
                    .font(TE.font(15, weight: .regular))
                    .foregroundColor(TE.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)
        }
    }

    // MARK: - Step 2: Name Profile
    private var nameStep: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("name your profile")
                    .font(TE.font(28, weight: .light))
                    .foregroundColor(TE.text)

                Text("give your first focus profile a name")
                    .font(TE.font(15, weight: .regular))
                    .foregroundColor(TE.textSecondary)
            }

            VStack(spacing: 24) {
                // Name field
                TextField("e.g. work mode, study time", text: $profileName)
                    .font(TE.font(18, weight: .regular))
                    .foregroundColor(TE.text)
                    .multilineTextAlignment(.center)
                    .padding(20)
                    .background(TE.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(profileName.isEmpty ? TE.border : TE.orange, lineWidth: 1)
                    )
                    .textInputAutocapitalization(.never)

                // Icon picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("choose an icon")
                        .font(TE.font(12, weight: .medium))
                        .foregroundColor(TE.textSecondary)

                    OnboardingIconPicker(selectedIcon: $selectedIcon)
                }
            }
            .padding(.horizontal, 32)
        }
    }

    // MARK: - Step 3: Select Apps
    private var appsStep: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("select apps to block")
                    .font(TE.font(28, weight: .light))
                    .foregroundColor(TE.text)

                Text("choose which apps and categories you want to block when this profile is active")
                    .font(TE.font(15, weight: .regular))
                    .foregroundColor(TE.textSecondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 16) {
                Button(action: { showingAppPicker = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(TE.orange)

                        Text(appsSelectedText)
                            .font(TE.font(16, weight: .medium))
                            .foregroundColor(TE.text)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(TE.textSecondary)
                    }
                    .padding(20)
                    .background(TE.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(hasSelectedApps ? TE.orange : TE.border, lineWidth: 1)
                    )
                }
                .buttonStyle(TEButtonStyle())

                if hasSelectedApps {
                    HStack(spacing: 16) {
                        statBadge(count: selectedApps.applicationTokens.count, label: "apps")
                        statBadge(count: selectedApps.categoryTokens.count, label: "categories")
                    }
                }
            }
            .padding(.horizontal, 32)
        }
    }

    // MARK: - Step 4: Done
    private var doneStep: some View {
        VStack(spacing: 32) {
            // Success icon
            ZStack {
                Circle()
                    .stroke(TE.border, lineWidth: 1)
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(TE.green)
                    .frame(width: 80, height: 80)

                Image(systemName: "checkmark")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.white)
            }

            VStack(spacing: 16) {
                Text("you're all set!")
                    .font(TE.font(28, weight: .light))
                    .foregroundColor(TE.text)

                Text("your profile '\(profileName)' is ready. tap any nfc tag to start blocking.")
                    .font(TE.font(15, weight: .regular))
                    .foregroundColor(TE.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)

            // Profile preview
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(TE.orange)
                        .frame(width: 50, height: 50)

                    Image(systemName: selectedIcon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(profileName)
                        .font(TE.font(16, weight: .medium))
                        .foregroundColor(TE.text)

                    Text("\(totalSelectedCount) items selected")
                        .font(TE.font(13, weight: .regular))
                        .foregroundColor(TE.textSecondary)
                }

                Spacer()
            }
            .padding(16)
            .background(TE.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(TE.border, lineWidth: 1)
            )
            .padding(.horizontal, 32)
        }
    }

    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentStep > 0 && currentStep < 3 {
                Button(action: previousStep) {
                    Text("back")
                        .font(TE.font(15, weight: .medium))
                        .foregroundColor(TE.textSecondary)
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

            Button(action: nextStep) {
                Text(nextButtonText)
                    .font(TE.font(15, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canProceed ? TE.orange : TE.border)
                    .cornerRadius(4)
            }
            .buttonStyle(TEButtonStyle())
            .disabled(!canProceed)
        }
    }

    // MARK: - Helper Views
    private func statBadge(count: Int, label: String) -> some View {
        HStack(spacing: 8) {
            Text("\(count)")
                .font(TE.mono(16, weight: .medium))
                .foregroundColor(TE.orange)

            Text(label)
                .font(TE.font(14, weight: .regular))
                .foregroundColor(TE.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(TE.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(TE.border, lineWidth: 1)
        )
    }

    // MARK: - Computed Properties
    private var hasSelectedApps: Bool {
        !selectedApps.applicationTokens.isEmpty || !selectedApps.categoryTokens.isEmpty
    }

    private var totalSelectedCount: Int {
        selectedApps.applicationTokens.count + selectedApps.categoryTokens.count
    }

    private var appsSelectedText: String {
        hasSelectedApps ? "edit selected apps" : "tap to select apps"
    }

    private var nextButtonText: String {
        switch currentStep {
        case 0: return "get started"
        case 1: return "next"
        case 2: return "create profile"
        case 3: return "start using focus"
        default: return "next"
        }
    }

    private var canProceed: Bool {
        switch currentStep {
        case 0: return true
        case 1: return !profileName.trimmingCharacters(in: .whitespaces).isEmpty
        case 2: return hasSelectedApps
        case 3: return true
        default: return true
        }
    }

    // MARK: - Actions
    private func previousStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep -= 1
        }
    }

    private func nextStep() {
        if currentStep == 2 {
            // Create the profile
            let profile = Profile(
                name: profileName.trimmingCharacters(in: .whitespaces),
                icon: selectedIcon,
                selectedApps: selectedApps,
                order: 0
            )
            profileManager.addProfile(profile)
        }

        if currentStep == 3 {
            // Complete onboarding
            profileManager.completeOnboarding()
            return
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep += 1
        }
    }
}

// MARK: - Onboarding Icon Picker
struct OnboardingIconPicker: View {
    @Binding var selectedIcon: String

    let icons = [
        "app.badge", "moon.fill", "briefcase.fill", "book.fill",
        "gamecontroller.fill", "tv.fill", "bubble.left.fill", "heart.fill"
    ]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(icons, id: \.self) { icon in
                Button(action: { selectedIcon = icon }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(selectedIcon == icon ? TE.orange : TE.surface)
                            .frame(width: 44, height: 44)
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

#Preview {
    OnboardingView()
        .environmentObject(ProfileManager())
}
