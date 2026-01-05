import Foundation
import FamilyControls

struct Profile: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var icon: String
    var isDefault: Bool
    var selectedApps: FamilyActivitySelection
    var order: Int

    init(
        id: UUID = UUID(),
        name: String,
        icon: String = "app.badge",
        isDefault: Bool = false,
        selectedApps: FamilyActivitySelection = FamilyActivitySelection(),
        order: Int = 0
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.isDefault = isDefault
        self.selectedApps = selectedApps
        self.order = order
    }

    // Custom coding for FamilyActivitySelection
    enum CodingKeys: String, CodingKey {
        case id, name, icon, isDefault, selectedAppsData, order
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        icon = try container.decode(String.self, forKey: .icon)
        isDefault = try container.decode(Bool.self, forKey: .isDefault)
        order = try container.decode(Int.self, forKey: .order)

        if let data = try container.decodeIfPresent(Data.self, forKey: .selectedAppsData) {
            selectedApps = (try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)) ?? FamilyActivitySelection()
        } else {
            selectedApps = FamilyActivitySelection()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(icon, forKey: .icon)
        try container.encode(isDefault, forKey: .isDefault)
        try container.encode(order, forKey: .order)

        let data = try? JSONEncoder().encode(selectedApps)
        try container.encodeIfPresent(data, forKey: .selectedAppsData)
    }

    static func == (lhs: Profile, rhs: Profile) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Default Profiles
extension Profile {
    static let highestScreenTime = Profile(
        name: "highest screen time",
        icon: "chart.bar.fill",
        isDefault: true,
        order: 0
    )

    static let entertainment = Profile(
        name: "are you not entertained",
        icon: "tv.fill",
        isDefault: true,
        order: 1
    )

    static let monkMode = Profile(
        name: "monk mode",
        icon: "moon.fill",
        isDefault: true,
        order: 2
    )
}
