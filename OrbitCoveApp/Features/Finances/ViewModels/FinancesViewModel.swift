import SwiftUI

@Observable
final class FinancesViewModel {
    var transactions: [LocalTransaction] = []
    var balance: Int = 0
    var activeDues: MockDues?
    var isLoading = false
    var error: Error?

    var recentTransactions: [LocalTransaction] {
        Array(transactions.prefix(5))
    }

    func loadTransactions() async {
        isLoading = true
        error = nil

        do {
            try await Task.sleep(for: .milliseconds(500))
            transactions = MockData.transactionsWithSplits
            balance = -4500 // $45.00 owed
            activeDues = MockDues(
                name: "2026 Season Dues",
                amount: 15000,
                dueDate: Date().addingTimeInterval(86400 * 30),
                paidCount: 8,
                totalCount: 12,
                isPaid: false
            )
        } catch {
            self.error = error
        }

        isLoading = false
    }
}
