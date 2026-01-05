import SwiftUI

// MARK: - Service Protocols

protocol AuthServiceProtocol {
    func signInWithApple() async throws -> LocalUser
    func signOut() async
    var isAuthenticated: Bool { get }
}

protocol CommunityServiceProtocol {
    func fetchCommunities() async throws -> [LocalCommunity]
    func createCommunity(name: String, type: CommunityType) async throws -> LocalCommunity
    func joinCommunity(code: String) async throws -> LocalCommunity
    func leaveCommunity(_ community: LocalCommunity) async throws
    func inviteMembers(to community: LocalCommunity) async throws -> String
}

protocol EventServiceProtocol {
    func fetchEvents(for community: LocalCommunity) async throws -> [LocalEvent]
    func createEvent(_ event: LocalEvent) async throws -> LocalEvent
    func updateEvent(_ event: LocalEvent) async throws -> LocalEvent
    func deleteEvent(_ event: LocalEvent) async throws
    func rsvp(to event: LocalEvent, status: RSVPStatus, note: String?) async throws
    func rsvpForFamilyMember(_ familyMember: LocalFamilyMember, to event: LocalEvent, status: RSVPStatus) async throws
}

protocol PostServiceProtocol {
    func fetchPosts(for community: LocalCommunity) async throws -> [LocalPost]
    func createPost(_ post: LocalPost) async throws -> LocalPost
    func updatePost(_ post: LocalPost) async throws -> LocalPost
    func deletePost(_ post: LocalPost) async throws
    func addReaction(_ reaction: ReactionType, to post: LocalPost) async throws
    func removeReaction(from post: LocalPost) async throws
    func addComment(_ content: String, to post: LocalPost) async throws -> LocalComment
}

protocol FinanceServiceProtocol {
    func fetchTransactions(for community: LocalCommunity) async throws -> [LocalTransaction]
    func createTransaction(_ transaction: LocalTransaction) async throws -> LocalTransaction
    func settleUp(with user: LocalUser) async throws
    func calculateBalance(for user: LocalUser, in community: LocalCommunity) -> Int
}

protocol SyncServiceProtocol {
    func sync(community: LocalCommunity) async throws
    func uploadPendingOperations() async throws
    var isSyncing: Bool { get }
}

// MARK: - Service Container

@Observable
final class ServiceContainer {
    static let shared = ServiceContainer()

    let authService: AuthServiceProtocol
    let communityService: CommunityServiceProtocol
    let eventService: EventServiceProtocol
    let postService: PostServiceProtocol
    let financeService: FinanceServiceProtocol
    let syncService: SyncServiceProtocol

    private init() {
        // Use mock services for now
        self.authService = MockAuthService()
        self.communityService = MockCommunityService()
        self.eventService = MockEventService()
        self.postService = MockPostService()
        self.financeService = MockFinanceService()
        self.syncService = MockSyncService()
    }
}

// MARK: - Environment Key

private struct ServiceContainerKey: EnvironmentKey {
    static let defaultValue = ServiceContainer.shared
}

extension EnvironmentValues {
    var services: ServiceContainer {
        get { self[ServiceContainerKey.self] }
        set { self[ServiceContainerKey.self] = newValue }
    }
}
