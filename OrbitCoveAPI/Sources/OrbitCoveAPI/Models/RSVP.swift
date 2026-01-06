import Fluent
import Foundation

/// RSVP status
enum RSVPStatus: String, Codable {
    case yes
    case no
    case maybe
}

final class RSVP: Model, @unchecked Sendable {
    static let schema = "rsvps"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "event_id")
    var event: Event

    @Parent(key: "user_id")
    var user: User

    @OptionalParent(key: "family_member_id")
    var familyMember: FamilyMember?

    @Enum(key: "status")
    var status: RSVPStatus

    @Field(key: "plus_ones")
    var plusOnes: Int

    @OptionalField(key: "note")
    var note: String?

    @Timestamp(key: "responded_at", on: .create)
    var respondedAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        eventId: UUID,
        userId: UUID,
        familyMemberId: UUID? = nil,
        status: RSVPStatus,
        plusOnes: Int = 0,
        note: String? = nil
    ) {
        self.id = id
        self.$event.id = eventId
        self.$user.id = userId
        if let familyMemberId = familyMemberId {
            self.$familyMember.id = familyMemberId
        }
        self.status = status
        self.plusOnes = plusOnes
        self.note = note
    }
}
