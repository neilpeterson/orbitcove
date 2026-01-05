import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    @State private var showCreateConversation = false

    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.conversations.isEmpty {
                LoadingView(message: "Loading conversations...")
            } else if viewModel.conversations.isEmpty {
                EmptyStateView(
                    icon: "bubble.left.and.bubble.right",
                    title: "No conversations yet",
                    message: "Start a conversation with your community members!",
                    actionTitle: "Start a Chat",
                    action: { showCreateConversation = true }
                )
            } else {
                conversationList
            }

            // FAB for new conversation
            if !viewModel.conversations.isEmpty {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showCreateConversation = true
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
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCreateConversation) {
            NavigationStack {
                CreateConversationView(viewModel: viewModel)
            }
        }
        .task {
            await viewModel.loadConversations()
        }
    }

    private var conversationList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.sortedConversations, id: \.id) { conversation in
                    NavigationLink {
                        ConversationDetailView(conversation: conversation, viewModel: viewModel)
                    } label: {
                        ConversationRow(conversation: conversation)
                    }
                    .buttonStyle(.plain)

                    Divider()
                        .padding(.leading, 76)
                }
            }
        }
        .refreshable {
            await viewModel.loadConversations()
        }
    }
}

struct ConversationRow: View {
    let conversation: LocalConversation

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Avatar
            ZStack {
                if conversation.isGroup {
                    Circle()
                        .fill(Theme.Colors.primary.opacity(0.2))
                        .frame(width: 52, height: 52)

                    Image(systemName: "person.3.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.Colors.primary)
                } else {
                    AvatarView(
                        name: conversation.displayName(currentUserId: MockData.currentUser.id),
                        imageUrl: nil,
                        size: 52
                    )
                }
            }

            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                HStack {
                    Text(conversation.displayName(currentUserId: MockData.currentUser.id))
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Spacer()

                    if let lastMessageAt = conversation.lastMessageAt {
                        Text(lastMessageAt.relativeTimeString)
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack {
                    if let lastMessage = conversation.lastMessageContent {
                        Text(lastMessage)
                            .font(Theme.Typography.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    Spacer()

                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(Theme.Typography.caption.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, Theme.Spacing.sm)
                            .padding(.vertical, Theme.Spacing.xxs)
                            .background(Theme.Colors.primary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
    .environment(AppState())
    .environment(\.services, ServiceContainer.shared)
}
