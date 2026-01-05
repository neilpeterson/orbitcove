import SwiftUI

struct FeedView: View {
    @State private var viewModel = FeedViewModel()
    @State private var showCreatePost = false

    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.posts.isEmpty {
                LoadingView(message: "Loading posts...")
            } else if viewModel.posts.isEmpty {
                EmptyStateView.noPosts {
                    showCreatePost = true
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.md) {
                        // Pinned posts
                        if !viewModel.pinnedPosts.isEmpty {
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Label("PINNED", systemImage: "pin.fill")
                                    .font(Theme.Typography.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, Theme.Spacing.md)

                                ForEach(viewModel.pinnedPosts, id: \.id) { post in
                                    NavigationLink {
                                        PostDetailView(post: post)
                                    } label: {
                                        PostCard(post: post)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            Divider()
                                .padding(.vertical, Theme.Spacing.sm)
                        }

                        // Regular posts
                        ForEach(viewModel.regularPosts, id: \.id) { post in
                            NavigationLink {
                                PostDetailView(post: post)
                            } label: {
                                PostCard(post: post)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(Theme.Spacing.md)
                }
                .refreshable {
                    await viewModel.loadPosts()
                }
            }

            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showCreatePost = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(Theme.Colors.primary)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(Theme.Spacing.lg)
                }
            }
        }
        .navigationTitle("Feed")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCreatePost) {
            NavigationStack {
                CreatePostView()
            }
        }
        .task {
            await viewModel.loadPosts()
        }
    }
}

struct PostCard: View {
    let post: LocalPost
    @State private var showReactionPicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Header
            HStack(spacing: Theme.Spacing.sm) {
                AvatarView(name: post.authorName, imageUrl: post.authorAvatarUrl, size: 40)

                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(post.authorName)
                        .font(Theme.Typography.headline)

                    Text(post.createdAt.relativeTimeString)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if post.isAnnouncement {
                    Image(systemName: "megaphone.fill")
                        .foregroundStyle(Theme.Colors.warning)
                }

                if post.syncStatus == .pendingUpload {
                    PendingSyncBadge()
                }
            }

            // Content
            if let content = post.content, !content.isEmpty {
                Text(content)
                    .font(Theme.Typography.body)
            }

            // Media
            if !post.mediaUrls.isEmpty {
                PostMediaView(urls: post.mediaUrls)
            }

            // Poll
            if let pollData = post.pollData {
                PollView(pollData: pollData)
            }

            // Event share
            if post.type == .eventShare, let eventId = post.linkedEventId {
                EventShareCard(eventId: eventId)
            }

            // Footer
            HStack(spacing: Theme.Spacing.lg) {
                // Reactions
                Button {
                    showReactionPicker.toggle()
                } label: {
                    HStack(spacing: Theme.Spacing.xs) {
                        ReactionSummary(reactionCounts: post.reactionCounts)

                        if post.totalReactions == 0 {
                            Image(systemName: "heart")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)

                // Comments
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "bubble.right")
                    Text("\(post.commentCount)")
                }
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.secondary)

                Spacer()

                Text(post.createdAt.relativeTimeString)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
        .overlay(alignment: .top) {
            if showReactionPicker {
                ReactionPicker { reaction in
                    showReactionPicker = false
                    // Handle reaction
                }
                .offset(y: -50)
            }
        }
    }
}

struct PostMediaView: View {
    let urls: [String]

    var body: some View {
        if urls.count == 1 {
            AsyncImage(url: URL(string: urls[0])) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Theme.Colors.tertiaryBackground)
                        .aspectRatio(16/9, contentMode: .fit)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: 300)
                        .clipped()
                case .failure:
                    Rectangle()
                        .fill(Theme.Colors.tertiaryBackground)
                        .aspectRatio(16/9, contentMode: .fit)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.tertiary)
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
        } else {
            // Grid for multiple images
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.xs) {
                ForEach(urls.prefix(4), id: \.self) { url in
                    Rectangle()
                        .fill(Theme.Colors.tertiaryBackground)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.tertiary)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.sm))
                }
            }
        }
    }
}

struct PollView: View {
    let pollData: PollData

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(pollData.question)
                .font(Theme.Typography.headline)

            ForEach(Array(pollData.options.enumerated()), id: \.offset) { index, option in
                PollOptionRow(
                    option: option,
                    votes: pollData.voteCount(for: index),
                    totalVotes: pollData.totalVotes,
                    isSelected: false
                )
            }

            Text("\(pollData.totalVotes) votes")
                .font(Theme.Typography.caption)
                .foregroundStyle(.secondary)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.tertiaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
    }
}

struct PollOptionRow: View {
    let option: String
    let votes: Int
    let totalVotes: Int
    let isSelected: Bool

    private var percentage: Double {
        guard totalVotes > 0 else { return 0 }
        return Double(votes) / Double(totalVotes)
    }

    var body: some View {
        Button {
            // Vote
        } label: {
            HStack {
                Text(option)
                    .font(Theme.Typography.subheadline)

                Spacer()

                Text("\(Int(percentage * 100))%")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(Theme.Spacing.sm)
            .background(
                GeometryReader { geo in
                    Rectangle()
                        .fill(Theme.Colors.primary.opacity(0.2))
                        .frame(width: geo.size.width * percentage)
                }
            )
            .background(Theme.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                    .stroke(isSelected ? Theme.Colors.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct EventShareCard: View {
    let eventId: UUID

    var body: some View {
        if let event = MockData.events.first(where: { $0.id == eventId }) {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundStyle(Theme.Colors.primary)

                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(event.title)
                        .font(Theme.Typography.headline)

                    Text("\(event.startsAt.shortDateString) at \(event.startsAt.timeString)")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)

                    if let location = event.locationName {
                        Text(location)
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Button("RSVP") {
                    // Navigate to event
                }
                .font(Theme.Typography.caption.weight(.semibold))
                .foregroundStyle(Theme.Colors.primary)
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.tertiaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
        }
    }
}

#Preview {
    NavigationStack {
        FeedView()
    }
    .environment(AppState())
}
