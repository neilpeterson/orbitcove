import SwiftUI

/// Defines the available feature modules that can be enabled/disabled per community
enum CommunityModule: String, Codable, CaseIterable, Identifiable {
    case dashboard = "dashboard"
    case calendar = "calendar"
    case feed = "feed"
    case chat = "chat"
    case finances = "finances"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .calendar: return "Calendar"
        case .feed: return "Feed"
        case .chat: return "Chat"
        case .finances: return "Finances"
        }
    }

    var icon: String {
        switch self {
        case .dashboard: return "square.grid.2x2"
        case .calendar: return "calendar"
        case .feed: return "newspaper"
        case .chat: return "bubble.left.and.bubble.right"
        case .finances: return "dollarsign.circle"
        }
    }

    var description: String {
        switch self {
        case .dashboard:
            return "Overview of upcoming events, recent activity, and announcements"
        case .calendar:
            return "Schedule and manage events with RSVP tracking"
        case .feed:
            return "Share updates, photos, polls, and announcements"
        case .chat:
            return "Direct messages and group conversations"
        case .finances:
            return "Track shared expenses and split bills"
        }
    }

    /// Default sort order for tabs
    var defaultOrder: Int {
        switch self {
        case .dashboard: return 0
        case .calendar: return 1
        case .feed: return 2
        case .chat: return 3
        case .finances: return 4
        }
    }
}
