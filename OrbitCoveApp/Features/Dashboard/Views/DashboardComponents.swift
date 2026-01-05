import SwiftUI

// MARK: - Announcement Card

struct AnnouncementCard: View {
    let post: LocalPost

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                AvatarView(name: post.authorName, imageUrl: post.authorAvatarUrl, size: 32)

                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(post.authorName)
                        .font(Theme.Typography.subheadline)
                        .fontWeight(.semibold)

                    Text(post.createdAt.relativeTimeString)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "megaphone.fill")
                    .foregroundStyle(Theme.Colors.warning)
            }

            if let content = post.content {
                Text(content)
                    .font(Theme.Typography.body)
                    .lineLimit(3)
            }
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.warning.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                .stroke(Theme.Colors.warning.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Dashboard Event Card

struct DashboardEventCard: View {
    let event: LocalEvent

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Date badge
            VStack(spacing: Theme.Spacing.xxs) {
                Text(event.startsAt.shortDayOfWeek)
                    .font(Theme.Typography.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                Text("\(Calendar.current.component(.day, from: event.startsAt))")
                    .font(Theme.Typography.title2)
                    .fontWeight(.bold)
            }
            .frame(width: 44)
            .padding(.vertical, Theme.Spacing.sm)
            .background(Theme.Colors.tertiaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))

            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(event.title)
                    .font(Theme.Typography.headline)
                    .lineLimit(1)

                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(event.startsAt.timeString)
                        .font(Theme.Typography.caption)
                }
                .foregroundStyle(.secondary)

                if let location = event.locationName {
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "location")
                            .font(.caption2)
                        Text(location)
                            .font(Theme.Typography.caption)
                            .lineLimit(1)
                    }
                    .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // RSVP summary
            if event.goingCount > 0 {
                VStack(spacing: Theme.Spacing.xxs) {
                    Text("\(event.goingCount)")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Colors.primary)
                    Text("going")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
    }
}

// MARK: - Dashboard Post Row

struct DashboardPostRow: View {
    let post: LocalPost

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            AvatarView(name: post.authorName, imageUrl: post.authorAvatarUrl, size: 40)

            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                HStack {
                    Text(post.authorName)
                        .font(Theme.Typography.subheadline)
                        .fontWeight(.semibold)

                    Spacer()

                    Text(post.createdAt.relativeTimeString)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.tertiary)
                }

                if let content = post.content {
                    Text(content)
                        .font(Theme.Typography.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                // Engagement metrics
                HStack(spacing: Theme.Spacing.md) {
                    if post.totalReactions > 0 {
                        Label("\(post.totalReactions)", systemImage: "heart")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }

                    if post.commentCount > 0 {
                        Label("\(post.commentCount)", systemImage: "bubble.right")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
    }
}

// MARK: - Section Headers

struct DashboardSectionHeader: View {
    let title: String
    let icon: String
    var iconColor: Color = Theme.Colors.primary
    var seeAllDestination: AnyView?

    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(Theme.Typography.headline)
                .foregroundStyle(iconColor)

            Spacer()

            if seeAllDestination != nil {
                NavigationLink("See All") {
                    seeAllDestination
                }
                .font(Theme.Typography.subheadline)
            }
        }
    }
}
