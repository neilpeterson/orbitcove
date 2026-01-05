import Foundation

/// Provides default module configurations based on community type
enum ModulePresets {
    /// Returns the default enabled modules for a given community type
    static func defaultModules(for communityType: CommunityType) -> [CommunityModule] {
        switch communityType {
        case .family:
            return [.dashboard, .calendar, .feed, .chat, .finances]
        case .team:
            // Teams typically don't need shared finances
            return [.dashboard, .calendar, .feed, .chat]
        case .club:
            return [.dashboard, .calendar, .feed, .chat, .finances]
        case .other:
            return [.dashboard, .calendar, .feed, .chat, .finances]
        }
    }

    /// All available modules sorted by default order
    static var allModules: [CommunityModule] {
        CommunityModule.allCases.sorted { $0.defaultOrder < $1.defaultOrder }
    }
}
