import Foundation

// MARK: - Mock Auth Service

final class MockAuthService: AuthServiceProtocol {
    private(set) var isAuthenticated: Bool = false

    func signInWithApple() async throws -> LocalUser {
        try await Task.sleep(for: .milliseconds(500))
        isAuthenticated = true
        return MockData.currentUser
    }

    func signOut() async {
        isAuthenticated = false
    }
}

// MARK: - Mock Community Service

final class MockCommunityService: CommunityServiceProtocol {
    func fetchCommunities() async throws -> [LocalCommunity] {
        try await Task.sleep(for: .milliseconds(300))
        return MockData.communities
    }

    func createCommunity(name: String, type: CommunityType) async throws -> LocalCommunity {
        try await Task.sleep(for: .milliseconds(500))
        return LocalCommunity(
            name: name,
            communityType: type,
            memberCount: 1
        )
    }

    func joinCommunity(code: String) async throws -> LocalCommunity {
        try await Task.sleep(for: .milliseconds(500))
        guard code.uppercased() == "ABC123" else {
            throw ServiceError.invalidInviteCode
        }
        return MockData.communities[1]
    }

    func leaveCommunity(_ community: LocalCommunity) async throws {
        try await Task.sleep(for: .milliseconds(300))
    }

    func inviteMembers(to community: LocalCommunity) async throws -> String {
        try await Task.sleep(for: .milliseconds(200))
        return "ABC123"
    }
}

// MARK: - Mock Event Service

final class MockEventService: EventServiceProtocol {
    func fetchEvents(for community: LocalCommunity) async throws -> [LocalEvent] {
        try await Task.sleep(for: .milliseconds(300))
        return MockData.events
    }

    func createEvent(_ event: LocalEvent) async throws -> LocalEvent {
        try await Task.sleep(for: .milliseconds(500))
        return event
    }

    func updateEvent(_ event: LocalEvent) async throws -> LocalEvent {
        try await Task.sleep(for: .milliseconds(300))
        return event
    }

    func deleteEvent(_ event: LocalEvent) async throws {
        try await Task.sleep(for: .milliseconds(300))
    }

    func rsvp(to event: LocalEvent, status: RSVPStatus, note: String?) async throws {
        try await Task.sleep(for: .milliseconds(200))
    }

    func rsvpForFamilyMember(_ familyMember: LocalFamilyMember, to event: LocalEvent, status: RSVPStatus) async throws {
        try await Task.sleep(for: .milliseconds(200))
    }
}

// MARK: - Mock Post Service

final class MockPostService: PostServiceProtocol {
    func fetchPosts(for community: LocalCommunity) async throws -> [LocalPost] {
        try await Task.sleep(for: .milliseconds(300))
        return MockData.posts
    }

    func createPost(_ post: LocalPost) async throws -> LocalPost {
        try await Task.sleep(for: .milliseconds(500))
        return post
    }

    func updatePost(_ post: LocalPost) async throws -> LocalPost {
        try await Task.sleep(for: .milliseconds(300))
        return post
    }

    func deletePost(_ post: LocalPost) async throws {
        try await Task.sleep(for: .milliseconds(300))
    }

    func addReaction(_ reaction: ReactionType, to post: LocalPost) async throws {
        try await Task.sleep(for: .milliseconds(100))
    }

    func removeReaction(from post: LocalPost) async throws {
        try await Task.sleep(for: .milliseconds(100))
    }

    func addComment(_ content: String, to post: LocalPost) async throws -> LocalComment {
        try await Task.sleep(for: .milliseconds(300))
        return LocalComment(
            content: content,
            authorId: MockData.currentUser.id,
            authorName: MockData.currentUser.displayName
        )
    }
}

// MARK: - Mock Finance Service

final class MockFinanceService: FinanceServiceProtocol {
    func fetchTransactions(for community: LocalCommunity) async throws -> [LocalTransaction] {
        try await Task.sleep(for: .milliseconds(300))
        return MockData.transactions
    }

    func createTransaction(_ transaction: LocalTransaction) async throws -> LocalTransaction {
        try await Task.sleep(for: .milliseconds(500))
        return transaction
    }

    func settleUp(with user: LocalUser) async throws {
        try await Task.sleep(for: .milliseconds(300))
    }

    func calculateBalance(for user: LocalUser, in community: LocalCommunity) -> Int {
        return -4500 // $45.00 owed
    }
}

// MARK: - Mock Sync Service

final class MockSyncService: SyncServiceProtocol {
    private(set) var isSyncing: Bool = false

    func sync(community: LocalCommunity) async throws {
        isSyncing = true
        try await Task.sleep(for: .milliseconds(1000))
        isSyncing = false
    }

    func uploadPendingOperations() async throws {
        try await Task.sleep(for: .milliseconds(500))
    }
}

// MARK: - Mock Chat Service

final class MockChatService: ChatServiceProtocol {
    func fetchConversations(for community: LocalCommunity) async throws -> [LocalConversation] {
        try await Task.sleep(for: .milliseconds(300))
        return MockData.conversations.sorted { ($0.lastMessageAt ?? .distantPast) > ($1.lastMessageAt ?? .distantPast) }
    }

    func fetchMessages(for conversation: LocalConversation) async throws -> [LocalMessage] {
        try await Task.sleep(for: .milliseconds(300))
        return MockData.messagesForConversation(conversation.id).sorted { $0.createdAt < $1.createdAt }
    }

    func createConversation(title: String?, participantIds: [UUID], participantNames: [String], isGroup: Bool) async throws -> LocalConversation {
        try await Task.sleep(for: .milliseconds(500))
        return LocalConversation(
            title: title,
            isGroup: isGroup,
            participantIds: participantIds,
            participantNames: participantNames
        )
    }

    func sendMessage(content: String, mediaUrls: [String], to conversation: LocalConversation) async throws -> LocalMessage {
        try await Task.sleep(for: .milliseconds(300))
        return LocalMessage(
            content: content,
            mediaUrls: mediaUrls,
            authorId: MockData.currentUser.id,
            authorName: MockData.currentUser.displayName
        )
    }

    func deleteMessage(_ message: LocalMessage) async throws {
        try await Task.sleep(for: .milliseconds(200))
    }

    func markAsRead(_ conversation: LocalConversation) async throws {
        try await Task.sleep(for: .milliseconds(100))
    }
}

// MARK: - Service Errors

enum ServiceError: LocalizedError {
    case networkError
    case invalidInviteCode
    case unauthorized
    case notFound
    case unknown

    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Unable to connect. Please check your internet connection."
        case .invalidInviteCode:
            return "Invalid invite code. Please check and try again."
        case .unauthorized:
            return "You don't have permission to perform this action."
        case .notFound:
            return "The requested content was not found."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
