import Fluent
import Foundation

/// Transaction type
enum TransactionType: String, Codable {
    case expense
    case settlement
    case dues
}

/// Expense category
enum ExpenseCategory: String, Codable {
    case equipment
    case food
    case travel
    case dues
    case other
}

final class Transaction: Model, @unchecked Sendable {
    static let schema = "transactions"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "community_id")
    var community: Community

    @Parent(key: "created_by")
    var createdBy: User

    @Enum(key: "type")
    var type: TransactionType

    @Field(key: "description")
    var description: String

    @Field(key: "total_amount")
    var totalAmount: Int  // stored in cents

    @Field(key: "currency")
    var currency: String

    @Parent(key: "paid_by")
    var paidBy: User

    @Enum(key: "category")
    var category: ExpenseCategory

    @OptionalField(key: "receipt_url")
    var receiptUrl: String?

    @OptionalParent(key: "linked_event_id")
    var linkedEvent: Event?

    @Field(key: "transaction_date")
    var transactionDate: Date

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @OptionalField(key: "deleted_at")
    var deletedAt: Date?

    // Relationships
    @Children(for: \.$transaction)
    var splits: [Split]

    init() {}

    init(
        id: UUID? = nil,
        communityId: UUID,
        createdById: UUID,
        type: TransactionType,
        description: String,
        totalAmount: Int,
        currency: String = "USD",
        paidById: UUID,
        category: ExpenseCategory = .other,
        receiptUrl: String? = nil,
        linkedEventId: UUID? = nil,
        transactionDate: Date
    ) {
        self.id = id
        self.$community.id = communityId
        self.$createdBy.id = createdById
        self.type = type
        self.description = description
        self.totalAmount = totalAmount
        self.currency = currency
        self.$paidBy.id = paidById
        self.category = category
        self.receiptUrl = receiptUrl
        if let linkedEventId = linkedEventId {
            self.$linkedEvent.id = linkedEventId
        }
        self.transactionDate = transactionDate
    }
}
