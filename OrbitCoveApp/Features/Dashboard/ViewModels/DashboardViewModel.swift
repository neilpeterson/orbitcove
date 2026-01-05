import SwiftUI

@Observable
final class DashboardViewModel {
    var isLoading = false
    var upcomingEvents: [LocalEvent] = []
    var recentPosts: [LocalPost] = []
    var announcements: [LocalPost] = []

    func loadDashboard() async {
        isLoading = true

        // Simulate network delay
        try? await Task.sleep(for: .milliseconds(300))

        // Load upcoming events (next 7 days)
        let now = Date()
        let weekFromNow = Calendar.current.date(byAdding: .day, value: 7, to: now) ?? now
        upcomingEvents = MockData.eventsWithRSVPs
            .filter { $0.startsAt > now && $0.startsAt < weekFromNow }
            .sorted { $0.startsAt < $1.startsAt }

        // Load posts
        let allPosts = MockData.postsWithComments

        // Announcements = pinned or announcement posts
        announcements = allPosts.filter { $0.isPinned || $0.isAnnouncement }

        // Recent activity = non-announcement posts
        recentPosts = allPosts
            .filter { !$0.isPinned && !$0.isAnnouncement }
            .sorted { $0.createdAt > $1.createdAt }

        isLoading = false
    }

    func refresh() async {
        await loadDashboard()
    }
}
