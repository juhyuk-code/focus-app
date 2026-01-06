import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity

class ProfileManager: ObservableObject {
    @Published var profiles: [Profile] = []
    @Published var activeProfile: Profile?
    @Published var hasCompletedOnboarding: Bool = false

    private let userDefaults = UserDefaults.standard
    private let profilesKey = "savedProfiles"
    private let onboardingKey = "hasCompletedOnboarding"
    private let store = ManagedSettingsStore()

    init() {
        loadOnboardingState()
        loadProfiles()
    }

    // MARK: - Onboarding

    private func loadOnboardingState() {
        hasCompletedOnboarding = userDefaults.bool(forKey: onboardingKey)
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        userDefaults.set(true, forKey: onboardingKey)
    }

    // MARK: - CRUD Operations

    func addProfile(_ profile: Profile) {
        var newProfile = profile
        newProfile.order = profiles.count
        profiles.append(newProfile)
        saveProfiles()
    }

    func updateProfile(_ profile: Profile) {
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index] = profile
            saveProfiles()
        }
    }

    func deleteProfile(_ profile: Profile) {
        profiles.removeAll { $0.id == profile.id }
        reorderProfiles()
        saveProfiles()
    }

    func moveProfile(from source: IndexSet, to destination: Int) {
        profiles.move(fromOffsets: source, toOffset: destination)
        reorderProfiles()
        saveProfiles()
    }

    // MARK: - Blocking

    func activateProfile(_ profile: Profile) {
        activeProfile = profile

        // Apply the blocking using the profile's selected apps
        store.shield.applications = profile.selectedApps.applicationTokens
        store.shield.applicationCategories = .specific(profile.selectedApps.categoryTokens)
        store.shield.webDomains = profile.selectedApps.webDomainTokens
    }

    func deactivateProfile() {
        activeProfile = nil

        // Remove all shields
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }

    var isBlocking: Bool {
        activeProfile != nil
    }

    // MARK: - Persistence

    private func loadProfiles() {
        guard let data = userDefaults.data(forKey: profilesKey),
              let decoded = try? JSONDecoder().decode([Profile].self, from: data) else {
            return
        }
        profiles = decoded.sorted { $0.order < $1.order }
    }

    private func saveProfiles() {
        guard let encoded = try? JSONEncoder().encode(profiles) else { return }
        userDefaults.set(encoded, forKey: profilesKey)
    }

    private func reorderProfiles() {
        for (index, _) in profiles.enumerated() {
            profiles[index].order = index
        }
    }

}
