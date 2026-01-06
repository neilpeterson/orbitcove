import Fluent
import Foundation

final class Split: Model, @unchecked Sendable {
    static let schema = "splits"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "transaction_id")
    var transaction: Transaction

    @Parent(key: "user_id")
    var user: User

    @Field(key: "amount")
    var amount: Int  // stored in cents

    @Field(key: "is_settled")
    var isSettled: Bool

    @OptionalField(key: "settled_at")
    var settledAt: Date?

    @OptionalField(key: "settled_via")
    var settledVia: String?

    init() {}

    init(
        id: UUID? = nil,
        transactionId: UUID,
        userId: UUID,
        amount: Int,
        isSettled: Bool = false
    ) {
        self.id = id
        self.$transaction.id = transactionId
        self.$user.id = userId
        self.amount = amount
        self.isSettled = isSettled
    }
}
