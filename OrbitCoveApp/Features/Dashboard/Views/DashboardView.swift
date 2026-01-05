import SwiftUI

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.lg) {
                // Announcements section
                if !viewModel.announcements.isEmpty {
                    announcementsSection
                }

                // Upcoming events section
                upcomingEventsSection

                // Recent activity section
                recentActivitySection
            }
            .padding(Theme.Spacing.md)
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadDashboard()
        }
        .overlay {
            if viewModel.isLoading && viewModel.upcomingEvents.isEmpty {
                LoadingView(message: "Loading dashboard...")
            }
        }
    }

    // MARK: - Announcements Section

    private var announcementsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Label("Announcements", systemImage: "megaphone.fill")
                .font(Theme.Typography.headline)
                .foregroundStyle(Theme.Colors.warning)

            ForEach(viewModel.announcements, id: \.id) { post in
                NavigationLink {
                    PostDetailView(post: post)
                } label: {
                    AnnouncementCard(post: post)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Upcoming Events Section

    private var upcomingEventsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Label("Upcoming Events", systemImage: "calendar")
                    .font(Theme.Typography.headline)

                Spacer()

                NavigationLink {
                    CalendarView()
                } label: {
                    Text("See All")
                        .font(Theme.Typography.subheadline)
                }
            }

            if viewModel.upcomingEvents.isEmpty {
                emptyEventsView
            } else {
                ForEach(viewModel.upcomingEvents.prefix(3), id: \.id) { event in
                    NavigationLink {
                        EventDetailView(event: event)
                    } label: {
                        DashboardEventCard(event: event)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var emptyEventsView: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "calendar.badge.plus")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)

            Text("No upcoming events")
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.secondary)

            Text("Events in the next 7 days will appear here")
                .font(Theme.Typography.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xl)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
    }

    // MARK: - Recent Activity Section

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Label("Recent Activity", systemImage: "clock")
                    .font(Theme.Typography.headline)

                Spacer()

                NavigationLink {
                    FeedView()
                } label: {
                    Text("See All")
                        .font(Theme.Typography.subheadline)
                }
            }

            if viewModel.recentPosts.isEmpty {
                emptyActivityView
            } else {
                ForEach(viewModel.recentPosts.prefix(5), id: \.id) { post in
                    NavigationLink {
                        PostDetailView(post: post)
                    } label: {
                        DashboardPostRow(post: post)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var emptyActivityView: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)

            Text("No recent activity")
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.secondary)

            Text("Posts from your community will appear here")
                .font(Theme.Typography.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xl)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
    .environment(AppState())
    .environment(\.services, ServiceContainer.shared)
}
