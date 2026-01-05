import SwiftUI

@Observable
final class ChatViewModel {
    var conversations: [LocalConversation] = []
    var selectedConversation: LocalConversation?
    var messages: [LocalMessage] = []
    var isLoading = false
    var isLoadingMessages = false
    var error: Error?

    var sortedConversations: [LocalConversation] {
        conversations.sorted { ($0.lastMessageAt ?? .distantPast) > ($1.lastMessageAt ?? .distantPast) }
    }

    func loadConversations() async {
        isLoading = true
        error = nil

        do {
            try await Task.sleep(for: .milliseconds(300))
            conversations = MockData.conversations
        } catch {
            self.error = error
        }

        isLoading = false
    }

    func loadMessages(for conversation: LocalConversation) async {
        isLoadingMessages = true
        selectedConversation = conversation

        do {
            try await Task.sleep(for: .milliseconds(300))
            messages = MockData.messagesForConversation(conversation.id)
                .sorted { $0.createdAt < $1.createdAt }
        } catch {
            self.error = error
        }

        isLoadingMessages = false
    }

    func sendMessage(content: String, mediaUrls: [String] = []) async {
        guard let conversation = selectedConversation else { return }
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !mediaUrls.isEmpty else { return }

        // Create message optimistically
        let newMessage = LocalMessage(
            content: content,
            mediaUrls: mediaUrls,
            authorId: MockData.currentUser.id,
            authorName: MockData.currentUser.displayName,
            syncStatus: .pendingUpload
        )

        // Add to local messages immediately
        messages.append(newMessage)

        // Update conversation's last message
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index].lastMessageContent = content.isEmpty ? "Sent a photo" : content
            conversations[index].lastMessageAt = Date()
        }

        // Simulate server sync
        try? await Task.sleep(for: .milliseconds(300))

        // Mark as synced
        if let messageIndex = messages.firstIndex(where: { $0.id == newMessage.id }) {
            messages[messageIndex].syncStatus = .synced
        }
    }

    func markAsRead(_ conversation: LocalConversation) async {
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index].unreadCount = 0
        }

        try? await Task.sleep(for: .milliseconds(100))
    }

    func createConversation(title: String?, participantIds: [UUID], participantNames: [String], isGroup: Bool) async -> LocalConversation? {
        let newConversation = LocalConversation(
            title: title,
            isGroup: isGroup,
            participantIds: participantIds,
            participantNames: participantNames
        )

        try? await Task.sleep(for: .milliseconds(500))

        conversations.insert(newConversation, at: 0)
        return newConversation
    }

    var totalUnreadCount: Int {
        conversations.reduce(0) { $0 + $1.unreadCount }
    }
}
