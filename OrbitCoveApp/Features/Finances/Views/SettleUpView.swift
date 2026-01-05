import SwiftUI

struct SettleUpView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            // Balance summary
            VStack(spacing: Theme.Spacing.md) {
                Text("You owe")
                    .font(Theme.Typography.subheadline)
                    .foregroundStyle(.secondary)

                Text("$45.00")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(Theme.Colors.error)
            }
            .padding(.top, Theme.Spacing.xl)

            Divider()

            // Simplified debts
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                Text("Simplified")
                    .font(Theme.Typography.headline)

                SettleUpRow(
                    name: "Coach Dan",
                    amount: 3000,
                    onPay: { openVenmo(to: "coachdan", amount: 30.00) },
                    onMarkPaid: { }
                )

                SettleUpRow(
                    name: "Sarah Johnson",
                    amount: 1500,
                    onPay: { openVenmo(to: "sarahj", amount: 15.00) },
                    onMarkPaid: { }
                )
            }
            .padding(Theme.Spacing.lg)

            Spacer()

            Text("\"Pay\" opens Venmo with the amount pre-filled")
                .font(Theme.Typography.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)
        }
        .navigationTitle("Settle Up")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }

    private func openVenmo(to username: String, amount: Double) {
        let amountString = String(format: "%.2f", amount)
        if let url = URL(string: "venmo://paycharge?txn=pay&recipients=\(username)&amount=\(amountString)") {
            openURL(url)
        }
    }
}

struct SettleUpRow: View {
    let name: String
    let amount: Int
    let onPay: () -> Void
    let onMarkPaid: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                AvatarView(name: name, size: 44)

                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(name)
                        .font(Theme.Typography.headline)

                    Text("You owe \(formattedAmount)")
                        .font(Theme.Typography.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            HStack(spacing: Theme.Spacing.md) {
                Button("Pay (Venmo)", action: onPay)
                    .buttonStyle(.primary)

                Button("Mark as Paid", action: onMarkPaid)
                    .buttonStyle(.secondary)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
    }

    private var formattedAmount: String {
        String(format: "$%.2f", Double(amount) / 100.0)
    }
}

struct TransactionDetailView: View {
    let transaction: LocalTransaction

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                // Header
                VStack(spacing: Theme.Spacing.md) {
                    Image(systemName: transaction.category.icon)
                        .font(.system(size: 48))
                        .foregroundStyle(Theme.Colors.primary)

                    Text(transaction.descriptionText)
                        .font(Theme.Typography.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text(transaction.formattedAmount)
                        .font(.system(size: 36, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.lg)

                Divider()

                // Details
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    DetailRow(icon: "person.fill", title: "Paid by") {
                        Text(transaction.paidByName)
                    }

                    DetailRow(icon: "calendar", title: "Date") {
                        Text(transaction.transactionDate.fullDateString)
                    }

                    DetailRow(icon: "tag.fill", title: "Category") {
                        Text(transaction.category.displayName)
                    }
                }

                Divider()

                // Splits
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    Text("Split Breakdown")
                        .font(Theme.Typography.headline)

                    ForEach(transaction.splits, id: \.id) { split in
                        HStack {
                            AvatarView(name: split.userName, size: 32)

                            Text(split.userName)
                                .font(Theme.Typography.body)

                            Spacer()

                            Text(split.formattedAmount)
                                .font(Theme.Typography.body)

                            if split.isSettled {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Theme.Colors.success)
                            }
                        }
                    }
                }
            }
            .padding(Theme.Spacing.lg)
        }
        .navigationTitle("Transaction")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AllTransactionsView: View {
    let transactions: [LocalTransaction]

    var body: some View {
        List {
            ForEach(transactions, id: \.id) { transaction in
                NavigationLink {
                    TransactionDetailView(transaction: transaction)
                } label: {
                    HStack {
                        Image(systemName: transaction.category.icon)
                            .foregroundStyle(Theme.Colors.primary)

                        VStack(alignment: .leading) {
                            Text(transaction.descriptionText)
                                .font(Theme.Typography.body)
                            Text(transaction.transactionDate.shortDateString)
                                .font(Theme.Typography.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(transaction.formattedAmount)
                            .font(Theme.Typography.body)
                    }
                }
            }
        }
        .navigationTitle("All Transactions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettleUpView()
    }
}
