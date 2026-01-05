import Foundation
import SwiftData

// MARK: - Enums

enum SyncStatus: String, Codable {
    case synced
    case pendingUpload
    case pendingUpdate
    case pendingDelete
    case conflicted
}

enum OperationType: String, Codable {
    case create
    case update
    case delete
}

enum MemberRole: String, Codable, CaseIterable {
    case admin
    case member

    var displayName: String {
        switch self {
        case .admin: return "Admin"
        case .member: return "Member"
        }
    }
}

enum RSVPStatus: String, Codable, CaseIterable {
    case yes
    case no
    case maybe

    var displayName: String {
        switch self {
        case .yes: return "Going"
        case .no: return "Not Going"
        case .maybe: return "Maybe"
        }
    }

    var icon: String {
        switch self {
        case .yes: return "checkmark.circle.fill"
        case .no: return "xmark.circle.fill"
        case .maybe: return "questionmark.circle.fill"
        }
    }
}

enum EventCategory: String, Codable, CaseIterable {
    case practice
    case game
    case meeting
    case social
    case other

    var displayName: String {
        switch self {
        case .practice: return "Practice"
        case .game: return "Game"
        case .meeting: return "Meeting"
        case .social: return "Social"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .practice: return "figure.run"
        case .game: return "sportscourt"
        case .meeting: return "person.3"
        case .social: return "party.popper"
        case .other: return "calendar"
        }
    }

    var color: String {
        switch self {
        case .practice: return "green"
        case .game: return "blue"
        case .meeting: return "purple"
        case .social: return "orange"
        case .other: return "gray"
        }
    }
}

enum PostType: String, Codable, CaseIterable {
    case text
    case photo
    case announcement
    case poll
    case eventShare

    var displayName: String {
        switch self {
        case .text: return "Text"
        case .photo: return "Photo"
        case .announcement: return "Announcement"
        case .poll: return "Poll"
        case .eventShare: return "Event"
        }
    }
}

enum ReactionType: String, Codable, CaseIterable {
    case like
    case love
    case laugh
    case celebrate

    var emoji: String {
        switch self {
        case .like: return "❤️"
        case .love: return "😍"
        case .laugh: return "😂"
        case .celebrate: return "🎉"
        }
    }
}

enum TransactionType: String, Codable, CaseIterable {
    case expense
    case settlement
    case dues

    var displayName: String {
        switch self {
        case .expense: return "Expense"
        case .settlement: return "Settlement"
        case .dues: return "Dues"
        }
    }
}

enum ExpenseCategory: String, Codable, CaseIterable {
    case equipment
    case food
    case travel
    case dues
    case other

    var displayName: String {
        switch self {
        case .equipment: return "Equipment"
        case .food: return "Food"
        case .travel: return "Travel"
        case .dues: return "Dues"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .equipment: return "sportscourt"
        case .food: return "fork.knife"
        case .travel: return "car"
        case .dues: return "dollarsign.circle"
        case .other: return "ellipsis.circle"
        }
    }
}

enum CommunityType: String, Codable, CaseIterable {
    case family
    case team
    case club
    case other

    var displayName: String {
        switch self {
        case .family: return "Family"
        case .team: return "Team"
        case .club: return "Club"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .family: return "figure.2.and.child.holdinghands"
        case .team: return "sportscourt"
        case .club: return "person.3"
        case .other: return "star"
        }
    }
}

// MARK: - Codable Structs

struct CommunitySettings: Codable {
    var allowMemberEvents: Bool = true
    var allowMemberPosts: Bool = true
    var defaultReminderHours: Int = 24
    var timezone: String = "America/New_York"

    /// Which modules are enabled for this community
    var enabledModules: [CommunityModule] = CommunityModule.allCases

    /// Factory method to create default settings for a community type
    static func defaultSettings(for type: CommunityType) -> CommunitySettings {
        var settings = CommunitySettings()
        settings.enabledModules = ModulePresets.defaultModules(for: type)
        return settings
    }
}

struct PollData: Codable {
    var question: String
    var options: [String]
    var allowMultiple: Bool
    var closesAt: Date?
    var votes: [UUID: [Int]] = [:]

    func voteCount(for optionIndex: Int) -> Int {
        votes.values.filter { $0.contains(optionIndex) }.count
    }

    var totalVotes: Int {
        votes.count
    }
}

// MARK: - SwiftData Models

@Model
final class LocalUser {
    @Attribute(.unique) var id: UUID
    var appleId: String
    var email: String
    var displayName: String
    var avatarUrl: String?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \LocalFamilyMember.user)
    var familyMembers: [LocalFamilyMember]

    @Relationship(inverse: \LocalMembership.user)
    var memberships: [LocalMembership]

    init(
        id: UUID = UUID(),
        appleId: String,
        email: String,
        displayName: String,
        avatarUrl: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.appleId = appleId
        self.email = email
        self.displayName = displayName
        self.avatarUrl = avatarUrl
        self.createdAt = createdAt
        self.familyMembers = []
        self.memberships = []
    }
}

@Model
final class LocalFamilyMember {
    @Attribute(.unique) var id: UUID
    var name: String
    var avatarUrl: String?
    var createdAt: Date

    var user: LocalUser?

    init(
        id: UUID = UUID(),
        name: String,
        avatarUrl: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.avatarUrl = avatarUrl
        self.createdAt = createdAt
    }
}

@Model
final class LocalCommunity {
    @Attribute(.unique) var id: UUID
    var name: String
    var descriptionText: String?
    var iconUrl: String?
    var communityType: CommunityType
    var memberCount: Int
    var settings: CommunitySettings
    var createdAt: Date
    var lastSyncedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \LocalEvent.community)
    var events: [LocalEvent]

    @Relationship(deleteRule: .cascade, inverse: \LocalPost.community)
    var posts: [LocalPost]

    @Relationship(deleteRule: .cascade, inverse: \LocalTransaction.community)
    var transactions: [LocalTransaction]

    @Relationship(inverse: \LocalMembership.community)
    var memberships: [LocalMembership]

    init(
        id: UUID = UUID(),
        name: String,
        descriptionText: String? = nil,
        iconUrl: String? = nil,
        communityType: CommunityType = .other,
        memberCount: Int = 1,
        settings: CommunitySettings = CommunitySettings(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.descriptionText = descriptionText
        self.iconUrl = iconUrl
        self.communityType = communityType
        self.memberCount = memberCount
        self.settings = settings
        self.createdAt = createdAt
        self.events = []
        self.posts = []
        self.transactions = []
        self.memberships = []
    }
}

@Model
final class LocalMembership {
    @Attribute(.unique) var id: UUID
    var role: MemberRole
    var nickname: String?
    var joinedAt: Date

    var user: LocalUser?
    var community: LocalCommunity?

    init(
        id: UUID = UUID(),
        role: MemberRole = .member,
        nickname: String? = nil,
        joinedAt: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.nickname = nickname
        self.joinedAt = joinedAt
    }
}

@Model
final class LocalEvent {
    @Attribute(.unique) var id: UUID
    var title: String
    var descriptionText: String?
    var startsAt: Date
    var endsAt: Date?
    var allDay: Bool
    var locationName: String?
    var locationLat: Double?
    var locationLng: Double?
    var locationAddress: String?
    var category: EventCategory
    var createdById: UUID
    var createdByName: String
    var createdAt: Date
    var syncStatus: SyncStatus

    @Relationship(deleteRule: .cascade, inverse: \LocalRSVP.event)
    var rsvps: [LocalRSVP]

    var community: LocalCommunity?

    init(
        id: UUID = UUID(),
        title: String,
        descriptionText: String? = nil,
        startsAt: Date,
        endsAt: Date? = nil,
        allDay: Bool = false,
        locationName: String? = nil,
        locationLat: Double? = nil,
        locationLng: Double? = nil,
        locationAddress: String? = nil,
        category: EventCategory = .other,
        createdById: UUID,
        createdByName: String,
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.title = title
        self.descriptionText = descriptionText
        self.startsAt = startsAt
        self.endsAt = endsAt
        self.allDay = allDay
        self.locationName = locationName
        self.locationLat = locationLat
        self.locationLng = locationLng
        self.locationAddress = locationAddress
        self.category = category
        self.createdById = createdById
        self.createdByName = createdByName
        self.createdAt = createdAt
        self.syncStatus = syncStatus
        self.rsvps = []
    }

    var goingCount: Int {
        rsvps.filter { $0.status == .yes }.count
    }

    var maybeCount: Int {
        rsvps.filter { $0.status == .maybe }.count
    }

    var notGoingCount: Int {
        rsvps.filter { $0.status == .no }.count
    }
}

@Model
final class LocalRSVP {
    @Attribute(.unique) var id: UUID
    var status: RSVPStatus
    var plusOnes: Int
    var note: String?
    var userId: UUID
    var userName: String
    var familyMemberId: UUID?
    var familyMemberName: String?
    var respondedAt: Date

    var event: LocalEvent?

    init(
        id: UUID = UUID(),
        status: RSVPStatus,
        plusOnes: Int = 0,
        note: String? = nil,
        userId: UUID,
        userName: String,
        familyMemberId: UUID? = nil,
        familyMemberName: String? = nil,
        respondedAt: Date = Date()
    ) {
        self.id = id
        self.status = status
        self.plusOnes = plusOnes
        self.note = note
        self.userId = userId
        self.userName = userName
        self.familyMemberId = familyMemberId
        self.familyMemberName = familyMemberName
        self.respondedAt = respondedAt
    }

    var displayName: String {
        familyMemberName ?? userName
    }
}

@Model
final class LocalPost {
    @Attribute(.unique) var id: UUID
    var type: PostType
    var content: String?
    var mediaUrls: [String]
    var isPinned: Bool
    var isAnnouncement: Bool
    var linkedEventId: UUID?
    var pollData: PollData?
    var reactionCounts: [String: Int]
    var commentCount: Int
    var createdAt: Date
    var authorId: UUID
    var authorName: String
    var authorAvatarUrl: String?
    var syncStatus: SyncStatus

    @Relationship(deleteRule: .cascade, inverse: \LocalComment.post)
    var comments: [LocalComment]

    var community: LocalCommunity?

    init(
        id: UUID = UUID(),
        type: PostType = .text,
        content: String? = nil,
        mediaUrls: [String] = [],
        isPinned: Bool = false,
        isAnnouncement: Bool = false,
        linkedEventId: UUID? = nil,
        pollData: PollData? = nil,
        reactionCounts: [String: Int] = [:],
        commentCount: Int = 0,
        createdAt: Date = Date(),
        authorId: UUID,
        authorName: String,
        authorAvatarUrl: String? = nil,
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.type = type
        self.content = content
        self.mediaUrls = mediaUrls
        self.isPinned = isPinned
        self.isAnnouncement = isAnnouncement
        self.linkedEventId = linkedEventId
        self.pollData = pollData
        self.reactionCounts = reactionCounts
        self.commentCount = commentCount
        self.createdAt = createdAt
        self.authorId = authorId
        self.authorName = authorName
        self.authorAvatarUrl = authorAvatarUrl
        self.syncStatus = syncStatus
        self.comments = []
    }

    var totalReactions: Int {
        reactionCounts.values.reduce(0, +)
    }
}

@Model
final class LocalComment {
    @Attribute(.unique) var id: UUID
    var content: String
    var authorId: UUID
    var authorName: String
    var authorAvatarUrl: String?
    var parentId: UUID?
    var createdAt: Date
    var syncStatus: SyncStatus

    var post: LocalPost?

    init(
        id: UUID = UUID(),
        content: String,
        authorId: UUID,
        authorName: String,
        authorAvatarUrl: String? = nil,
        parentId: UUID? = nil,
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.content = content
        self.authorId = authorId
        self.authorName = authorName
        self.authorAvatarUrl = authorAvatarUrl
        self.parentId = parentId
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}

@Model
final class LocalTransaction {
    @Attribute(.unique) var id: UUID
    var type: TransactionType
    var descriptionText: String
    var totalAmount: Int
    var currency: String
    var paidById: UUID
    var paidByName: String
    var category: ExpenseCategory
    var receiptUrl: String?
    var linkedEventId: UUID?
    var transactionDate: Date
    var createdAt: Date
    var syncStatus: SyncStatus

    @Relationship(deleteRule: .cascade, inverse: \LocalSplit.transaction)
    var splits: [LocalSplit]

    var community: LocalCommunity?

    init(
        id: UUID = UUID(),
        type: TransactionType = .expense,
        descriptionText: String,
        totalAmount: Int,
        currency: String = "USD",
        paidById: UUID,
        paidByName: String,
        category: ExpenseCategory = .other,
        receiptUrl: String? = nil,
        linkedEventId: UUID? = nil,
        transactionDate: Date = Date(),
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.type = type
        self.descriptionText = descriptionText
        self.totalAmount = totalAmount
        self.currency = currency
        self.paidById = paidById
        self.paidByName = paidByName
        self.category = category
        self.receiptUrl = receiptUrl
        self.linkedEventId = linkedEventId
        self.transactionDate = transactionDate
        self.createdAt = createdAt
        self.syncStatus = syncStatus
        self.splits = []
    }

    var formattedAmount: String {
        let dollars = Double(totalAmount) / 100.0
        return String(format: "$%.2f", dollars)
    }
}

@Model
final class LocalSplit {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var userName: String
    var amount: Int
    var isSettled: Bool
    var settledAt: Date?
    var settledVia: String?

    var transaction: LocalTransaction?

    init(
        id: UUID = UUID(),
        userId: UUID,
        userName: String,
        amount: Int,
        isSettled: Bool = false,
        settledAt: Date? = nil,
        settledVia: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.amount = amount
        self.isSettled = isSettled
        self.settledAt = settledAt
        self.settledVia = settledVia
    }

    var formattedAmount: String {
        let dollars = Double(amount) / 100.0
        return String(format: "$%.2f", dollars)
    }
}

@Model
final class PendingOperation {
    @Attribute(.unique) var id: UUID
    var operationType: OperationType
    var entityType: String
    var entityId: UUID
    var payload: Data
    var createdAt: Date
    var retryCount: Int
    var lastError: String?

    init(
        id: UUID = UUID(),
        operationType: OperationType,
        entityType: String,
        entityId: UUID,
        payload: Data,
        createdAt: Date = Date(),
        retryCount: Int = 0,
        lastError: String? = nil
    ) {
        self.id = id
        self.operationType = operationType
        self.entityType = entityType
        self.entityId = entityId
        self.payload = payload
        self.createdAt = createdAt
        self.retryCount = retryCount
        self.lastError = lastError
    }
}
