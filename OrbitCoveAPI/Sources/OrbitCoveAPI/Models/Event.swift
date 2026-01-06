import Fluent
import Foundation

/// Event category type
enum EventCategory: String, Codable {
    case practice
    case game
    case meeting
    case social
    case other
}

final class Event: Model, @unchecked Sendable {
    static let schema = "events"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "community_id")
    var community: Community

    @Parent(key: "created_by")
    var createdBy: User

    @Field(key: "title")
    var title: String

    @OptionalField(key: "description")
    var description: String?

    @Field(key: "starts_at")
    var startsAt: Date

    @OptionalField(key: "ends_at")
    var endsAt: Date?

    @Field(key: "all_day")
    var allDay: Bool

    @OptionalField(key: "location_name")
    var locationName: String?

    @OptionalField(key: "location_lat")
    var locationLat: Double?

    @OptionalField(key: "location_lng")
    var locationLng: Double?

    @OptionalField(key: "location_address")
    var locationAddress: String?

    @Enum(key: "category")
    var category: EventCategory

    @OptionalField(key: "recurrence_rule")
    var recurrenceRule: String?

    @OptionalParent(key: "recurrence_parent_id")
    var recurrenceParent: Event?

    @Field(key: "attachments")
    var attachments: [String]

    @OptionalField(key: "rsvp_deadline")
    var rsvpDeadline: Date?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @OptionalField(key: "deleted_at")
    var deletedAt: Date?

    // Relationships
    @Children(for: \.$event)
    var rsvps: [RSVP]

    init() {}

    init(
        id: UUID? = nil,
        communityId: UUID,
        createdById: UUID,
        title: String,
        description: String? = nil,
        startsAt: Date,
        endsAt: Date? = nil,
        allDay: Bool = false,
        locationName: String? = nil,
        category: EventCategory = .other
    ) {
        self.id = id
        self.$community.id = communityId
        self.$createdBy.id = createdById
        self.title = title
        self.description = description
        self.startsAt = startsAt
        self.endsAt = endsAt
        self.allDay = allDay
        self.locationName = locationName
        self.category = category
        self.attachments = []
    }
}
