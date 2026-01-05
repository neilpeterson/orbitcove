import SwiftUI

struct MessageBubble: View {
    let message: LocalMessage
    let isCurrentUser: Bool
    let showAvatar: Bool

    @State private var showFullScreenImage = false
    @State private var selectedImageUrl: String?

    var body: some View {
        HStack(alignment: .bottom, spacing: Theme.Spacing.sm) {
            if isCurrentUser {
                Spacer(minLength: 60)
            } else if showAvatar {
                AvatarView(
                    name: message.authorName,
                    imageUrl: message.authorAvatarUrl,
                    size: 32
                )
            } else {
                Spacer()
                    .frame(width: 32)
            }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: Theme.Spacing.xxs) {
                // Author name for group chats
                if showAvatar && !isCurrentUser {
                    Text(message.authorName)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                }

                // Message content
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    // Images
                    if message.hasMedia {
                        mediaContent
                    }

                    // Text content
                    if !message.content.isEmpty {
                        Text(message.content)
                            .font(Theme.Typography.body)
                            .foregroundStyle(isCurrentUser ? .white : .primary)
                    }
                }
                .padding(Theme.Spacing.md)
                .background(bubbleBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))

                // Timestamp and status
                HStack(spacing: Theme.Spacing.xs) {
                    Text(message.createdAt.shortTimeString)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.tertiary)

                    if message.isEdited {
                        Text("(edited)")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.tertiary)
                    }

                    if isCurrentUser && message.syncStatus == .pendingUpload {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    } else if isCurrentUser && message.syncStatus == .synced {
                        Image(systemName: "checkmark")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            if !isCurrentUser {
                Spacer(minLength: 60)
            }
        }
        .sheet(isPresented: $showFullScreenImage) {
            if let imageUrl = selectedImageUrl {
                FullScreenImageView(imageUrl: imageUrl)
            }
        }
    }

    private var bubbleBackground: Color {
        isCurrentUser ? Theme.Colors.primary : Theme.Colors.secondaryBackground
    }

    @ViewBuilder
    private var mediaContent: some View {
        let urls = message.mediaUrls

        if urls.count == 1 {
            singleImage(url: urls[0])
        } else {
            imageGrid(urls: urls)
        }
    }

    private func singleImage(url: String) -> some View {
        Button {
            selectedImageUrl = url
            showFullScreenImage = true
        } label: {
            // Placeholder for actual image loading
            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                .fill(Color.gray.opacity(0.3))
                .frame(maxWidth: 200, maxHeight: 200)
                .overlay {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
        }
        .buttonStyle(.plain)
    }

    private func imageGrid(urls: [String]) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.xs) {
            ForEach(urls.prefix(4), id: \.self) { url in
                Button {
                    selectedImageUrl = url
                    showFullScreenImage = true
                } label: {
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(1, contentMode: .fill)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.secondary)
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: 200)
    }
}

struct FullScreenImageView: View {
    let imageUrl: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                // Placeholder for actual image
                VStack {
                    Image(systemName: "photo")
                        .font(.system(size: 100))
                        .foregroundStyle(.white.opacity(0.5))

                    Text("Image would load here")
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

extension Date {
    var shortTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

#Preview("Current User Message") {
    VStack {
        MessageBubble(
            message: LocalMessage(
                content: "Hey! How's it going?",
                authorId: MockData.currentUser.id,
                authorName: MockData.currentUser.displayName
            ),
            isCurrentUser: true,
            showAvatar: false
        )

        MessageBubble(
            message: LocalMessage(
                content: "Great, thanks for asking! Ready for practice tomorrow?",
                authorId: MockData.coachDan.id,
                authorName: MockData.coachDan.displayName
            ),
            isCurrentUser: false,
            showAvatar: true
        )

        MessageBubble(
            message: LocalMessage(
                content: "Check out this photo!",
                mediaUrls: ["https://example.com/photo.jpg"],
                authorId: MockData.currentUser.id,
                authorName: MockData.currentUser.displayName
            ),
            isCurrentUser: true,
            showAvatar: false
        )
    }
    .padding()
}
