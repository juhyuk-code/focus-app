import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity

class AppBlockingManager: ObservableObject {
    @Published var selectedApps: FamilyActivitySelection = FamilyActivitySelection()

    private let store = ManagedSettingsStore()
    private let userDefaultsKey = "SelectedAppsData"

    init() {
        loadSelectedApps()
    }

    // MARK: - App Selection Persistence

    func saveSelectedApps() {
        do {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(selectedApps)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
            print("Saved \(selectedApps.applicationTokens.count) apps and \(selectedApps.categoryTokens.count) categories")
        } catch {
            print("Failed to save selected apps: \(error)")
        }
    }

    private func loadSelectedApps() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            print("No saved app selection found")
            return
        }

        do {
            let decoder = PropertyListDecoder()
            selectedApps = try decoder.decode(FamilyActivitySelection.self, from: data)
            print("Loaded \(selectedApps.applicationTokens.count) apps and \(selectedApps.categoryTokens.count) categories")
        } catch {
            print("Failed to load selected apps: \(error)")
        }
    }

    // MARK: - App Blocking

    func blockApps() {
        // Block selected applications
        store.shield.applications = selectedApps.applicationTokens.isEmpty ? nil : selectedApps.applicationTokens

        // Block selected categories
        store.shield.applicationCategories = selectedApps.categoryTokens.isEmpty ? nil : .specific(selectedApps.categoryTokens)

        // Block web domains in selected categories
        store.shield.webDomainCategories = selectedApps.categoryTokens.isEmpty ? nil : .specific(selectedApps.categoryTokens)

        print("Blocked \(selectedApps.applicationTokens.count) apps and \(selectedApps.categoryTokens.count) categories")
    }

    func unblockApps() {
        // Remove all shields
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomainCategories = nil

        print("Unblocked all apps")
    }

    // MARK: - Utility

    var hasSelectedApps: Bool {
        !selectedApps.applicationTokens.isEmpty || !selectedApps.categoryTokens.isEmpty
    }

    func clearSelection() {
        selectedApps = FamilyActivitySelection()
        saveSelectedApps()
        unblockApps()
    }
}
