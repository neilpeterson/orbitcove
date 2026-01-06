import Fluent
import Foundation

/// Subscription status for a community
enum SubscriptionStatus: String, Codable {
    case free
    case active
    case pastDue = "past_due"
    case canceled
}

/// Community settings stored as JSON
struct CommunitySettings: Codable {
    var allowMemberEvents: Bool = true
    var allowMemberPosts: Bool = true
    var defaultReminderHours: Int = 24
    var timezone: String = "America/New_York"
}

final class Community: Model, @unchecked Sendable {
    static let schema = "communities"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @OptionalField(key: "description")
    var description: String?

    @OptionalField(key: "icon_url")
    var iconUrl: String?

    @Parent(key: "created_by")
    var createdBy: User

    @Field(key: "member_count")
    var memberCount: Int

    @Enum(key: "subscription_status")
    var subscriptionStatus: SubscriptionStatus

    @OptionalField(key: "subscription_expires_at")
    var subscriptionExpiresAt: Date?

    @OptionalField(key: "stripe_customer_id")
    var stripeCustomerId: String?

    @OptionalField(key: "stripe_subscription_id")
    var stripeSubscriptionId: String?

    @Field(key: "settings")
    var settings: CommunitySettings

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @OptionalField(key: "deleted_at")
    var deletedAt: Date?

    // Relationships
    @Children(for: \.$community)
    var members: [Member]

    @Children(for: \.$community)
    var events: [Event]

    @Children(for: \.$community)
    var posts: [Post]

    @Children(for: \.$community)
    var transactions: [Transaction]

    @Children(for: \.$community)
    var invites: [Invite]

    init() {}

    init(
        id: UUID? = nil,
        name: String,
        description: String? = nil,
        iconUrl: String? = nil,
        createdById: UUID,
        settings: CommunitySettings = CommunitySettings()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.iconUrl = iconUrl
        self.$createdBy.id = createdById
        self.memberCount = 1
        self.subscriptionStatus = .free
        self.settings = settings
    }
}
