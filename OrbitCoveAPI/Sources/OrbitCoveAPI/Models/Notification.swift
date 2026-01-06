import Fluent
import Foundation

/// Notification type
enum NotificationType: String, Codable {
    case eventReminder = "event_reminder"
    case newPost = "new_post"
    case mention
    case rsvpRequest = "rsvp_request"
    case paymentRequest = "payment_request"
}

/// Deep link data for notifications
struct NotificationData: Codable {
    var screen: String?
    var communityId: UUID?
    var entityId: UUID?
    var entityType: String?
}

final class Notification: Model, @unchecked Sendable {
    static let schema = "notifications"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @OptionalParent(key: "community_id")
    var community: Community?

    @Enum(key: "type")
    var type: NotificationType

    @Field(key: "title")
    var title: String

    @Field(key: "body")
    var body: String

    @Field(key: "data")
    var data: NotificationData

    @OptionalField(key: "read_at")
    var readAt: Date?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        userId: UUID,
        communityId: UUID? = nil,
        type: NotificationType,
        title: String,
        body: String,
        data: NotificationData = NotificationData()
    ) {
        self.id = id
        self.$user.id = userId
        if let communityId = communityId {
            self.$community.id = communityId
        }
        self.type = type
        self.title = title
        self.body = body
        self.data = data
    }
}
