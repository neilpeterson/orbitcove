import Fluent
import Foundation

final class DuesPayment: Model, @unchecked Sendable {
    static let schema = "dues_payments"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "dues_id")
    var dues: Dues

    @Parent(key: "user_id")
    var user: User

    @Field(key: "amount_paid")
    var amountPaid: Int  // stored in cents

    @Timestamp(key: "paid_at", on: .create)
    var paidAt: Date?

    @Parent(key: "recorded_by")
    var recordedBy: User

    @OptionalField(key: "payment_method")
    var paymentMethod: String?

    @OptionalField(key: "notes")
    var notes: String?

    init() {}

    init(
        id: UUID? = nil,
        duesId: UUID,
        userId: UUID,
        amountPaid: Int,
        recordedById: UUID,
        paymentMethod: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.$dues.id = duesId
        self.$user.id = userId
        self.amountPaid = amountPaid
        self.$recordedBy.id = recordedById
        self.paymentMethod = paymentMethod
        self.notes = notes
    }
}
