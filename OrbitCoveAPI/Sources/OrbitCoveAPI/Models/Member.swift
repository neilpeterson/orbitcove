import Fluent
import Foundation

/// Role within a community
enum MemberRole: String, Codable {
    case admin
    case member
}

/// Per-community notification preferences
struct NotificationPrefs: Codable {
    var events: Bool = true
    var posts: Bool = true
    var finances: Bool = true
    var mentions: Bool = true
}

final class Member: Model, @unchecked Sendable {
    static let schema = "members"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "community_id")
    var community: Community

    @Parent(key: "user_id")
    var user: User

    @Enum(key: "role")
    var role: MemberRole

    @OptionalField(key: "nickname")
    var nickname: String?

    @Field(key: "notification_prefs")
    var notificationPrefs: NotificationPrefs

    @Timestamp(key: "joined_at", on: .create)
    var joinedAt: Date?

    @OptionalParent(key: "invited_by")
    var invitedBy: User?

    @OptionalField(key: "left_at")
    var leftAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        communityId: UUID,
        userId: UUID,
        role: MemberRole = .member,
        nickname: String? = nil,
        invitedById: UUID? = nil
    ) {
        self.id = id
        self.$community.id = communityId
        self.$user.id = userId
        self.role = role
        self.nickname = nickname
        self.notificationPrefs = NotificationPrefs()
        if let invitedById = invitedById {
            self.$invitedBy.id = invitedById
        }
    }
}
