import SwiftUI

struct PostDetailView: View {
    let post: LocalPost
    @State private var newComment = ""
    @State private var showReactionPicker = false
    @FocusState private var isCommentFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // Author header
                    HStack(spacing: Theme.Spacing.sm) {
                        AvatarView(name: post.authorName, imageUrl: post.authorAvatarUrl, size: 48)

                        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                            Text(post.authorName)
                                .font(Theme.Typography.headline)

                            Text(post.createdAt.relativeTimeString)
                                .font(Theme.Typography.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
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

                    // Reactions row
                    HStack(spacing: Theme.Spacing.lg) {
                        Button {
                            showReactionPicker.toggle()
                        } label: {
                            HStack(spacing: Theme.Spacing.xs) {
                                ReactionSummary(reactionCounts: post.reactionCounts, showCount: true)

                                if post.totalReactions == 0 {
                                    Label("React", systemImage: "heart")
                                }
                            }
                        }
                        .buttonStyle(.plain)

                        Spacer()
                    }
                    .foregroundStyle(.secondary)
                    .overlay(alignment: .topLeading) {
                        if showReactionPicker {
                            ReactionPicker { _ in
                                showReactionPicker = false
                            }
                            .offset(y: -50)
                        }
                    }

                    Divider()

                    // Comments section
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("\(post.comments.count) Comments")
                            .font(Theme.Typography.headline)

                        ForEach(post.comments, id: \.id) { comment in
                            CommentRow(comment: comment)
                        }

                        if post.comments.isEmpty {
                            Text("No comments yet. Be the first to comment!")
                                .font(Theme.Typography.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.vertical, Theme.Spacing.lg)
                        }
                    }
                }
                .padding(Theme.Spacing.lg)
            }

            // Comment input
            Divider()

            HStack(spacing: Theme.Spacing.sm) {
                TextField("Add a comment...", text: $newComment)
                    .textFieldStyle(.plain)
                    .padding(Theme.Spacing.sm)
                    .background(Theme.Colors.tertiaryBackground)
                    .clipShape(Capsule())
                    .focused($isCommentFocused)

                Button {
                    submitComment()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(newComment.isEmpty ? Color.gray.opacity(0.3) : Theme.Colors.primary)
                }
                .disabled(newComment.isEmpty)
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.secondaryBackground)
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func submitComment() {
        guard !newComment.isEmpty else { return }
        // Add comment
        newComment = ""
        isCommentFocused = false
    }
}

struct CommentRow: View {
    let comment: LocalComment

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            AvatarView(name: comment.authorName, imageUrl: comment.authorAvatarUrl, size: 32)

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                HStack {
                    Text(comment.authorName)
                        .font(Theme.Typography.subheadline)
                        .fontWeight(.medium)

                    Text(comment.createdAt.relativeTimeString)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.tertiary)
                }

                Text(comment.content)
                    .font(Theme.Typography.body)
            }

            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        PostDetailView(post: MockData.postsWithComments[1])
    }
}
