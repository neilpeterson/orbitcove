import Fluent
import Foundation

final class Dues: Model, @unchecked Sendable {
    static let schema = "dues"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "community_id")
    var community: Community

    @Field(key: "name")
    var name: String

    @Field(key: "amount")
    var amount: Int  // stored in cents

    @Field(key: "due_date")
    var dueDate: Date

    @Field(key: "is_active")
    var isActive: Bool

    @Parent(key: "created_by")
    var createdBy: User

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    // Relationships
    @Children(for: \.$dues)
    var payments: [DuesPayment]

    init() {}

    init(
        id: UUID? = nil,
        communityId: UUID,
        name: String,
        amount: Int,
        dueDate: Date,
        isActive: Bool = true,
        createdById: UUID
    ) {
        self.id = id
        self.$community.id = communityId
        self.name = name
        self.amount = amount
        self.dueDate = dueDate
        self.isActive = isActive
        self.$createdBy.id = createdById
    }
}
