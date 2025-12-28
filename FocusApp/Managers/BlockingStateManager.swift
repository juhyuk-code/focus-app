import Foundation
import SwiftUI

class BlockingStateManager: ObservableObject {
    @Published private(set) var isBlocking: Bool = false
    @Published private(set) var lastToggleDate: Date?
    @Published private(set) var blockingStartDate: Date?

    private let isBlockingKey = "IsBlockingApps"
    private let lastToggleDateKey = "LastToggleDate"
    private let blockingStartDateKey = "BlockingStartDate"

    init() {
        loadState()
    }

    // MARK: - State Management

    func setBlocking(_ blocking: Bool) {
        isBlocking = blocking
        lastToggleDate = Date()

        if blocking {
            blockingStartDate = Date()
        } else {
            blockingStartDate = nil
        }

        saveState()
    }

    // MARK: - Persistence

    private func saveState() {
        UserDefaults.standard.set(isBlocking, forKey: isBlockingKey)
        UserDefaults.standard.set(lastToggleDate, forKey: lastToggleDateKey)
        UserDefaults.standard.set(blockingStartDate, forKey: blockingStartDateKey)
        print("Saved blocking state: \(isBlocking)")
    }

    private func loadState() {
        isBlocking = UserDefaults.standard.bool(forKey: isBlockingKey)
        lastToggleDate = UserDefaults.standard.object(forKey: lastToggleDateKey) as? Date
        blockingStartDate = UserDefaults.standard.object(forKey: blockingStartDateKey) as? Date

        print("Loaded blocking state: \(isBlocking)")

        // Re-apply blocking if it was active
        if isBlocking {
            print("Blocking was active, state persisted")
        }
    }

    // MARK: - Statistics

    var blockingDuration: TimeInterval? {
        guard let startDate = blockingStartDate, isBlocking else {
            return nil
        }
        return Date().timeIntervalSince(startDate)
    }

    var formattedBlockingDuration: String {
        guard let duration = blockingDuration else {
            return "Not blocking"
        }

        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }

    var lastToggleFormatted: String {
        guard let date = lastToggleDate else {
            return "Never"
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
