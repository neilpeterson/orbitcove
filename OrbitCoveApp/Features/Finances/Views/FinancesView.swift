import SwiftUI

struct FinancesView: View {
    @State private var viewModel = FinancesViewModel()
    @State private var showAddExpense = false
    @State private var showSettleUp = false

    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.transactions.isEmpty {
                LoadingView(message: "Loading finances...")
            } else if viewModel.transactions.isEmpty && viewModel.balance == 0 {
                EmptyStateView.noTransactions {
                    showAddExpense = true
                }
            } else {
                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        // Balance card
                        BalanceCard(
                            balance: viewModel.balance,
                            onSettleUp: { showSettleUp = true }
                        )

                        // Dues section (if any active)
                        if let activeDues = viewModel.activeDues {
                            DuesCard(dues: activeDues)
                        }

                        // Recent transactions
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            HStack {
                                Text("Recent Activity")
                                    .font(Theme.Typography.headline)

                                Spacer()

                                NavigationLink("See All") {
                                    AllTransactionsView(transactions: viewModel.transactions)
                                }
                                .font(Theme.Typography.subheadline)
                            }

                            ForEach(viewModel.recentTransactions, id: \.id) { transaction in
                                NavigationLink {
                                    TransactionDetailView(transaction: transaction)
                                } label: {
                                    TransactionRow(
                                        transaction: transaction,
                                        currentUserId: MockData.currentUser.id
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(Theme.Spacing.md)
                }
                .refreshable {
                    await viewModel.loadTransactions()
                }
            }

            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showAddExpense = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(Theme.Colors.primary)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(Theme.Spacing.lg)
                }
            }
        }
        .navigationTitle("Finances")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddExpense) {
            NavigationStack {
                AddExpenseView()
            }
        }
        .sheet(isPresented: $showSettleUp) {
            NavigationStack {
                SettleUpView()
            }
        }
        .task {
            await viewModel.loadTransactions()
        }
    }
}

struct BalanceCard: View {
    let balance: Int
    let onSettleUp: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Text("Your Balance")
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.secondary)

            Text(formattedBalance)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(balanceColor)

            Text(balanceMessage)
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.secondary)

            if balance != 0 {
                Button("Settle Up", action: onSettleUp)
                    .buttonStyle(.primary)
                    .padding(.top, Theme.Spacing.sm)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.xl)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
    }

    private var formattedBalance: String {
        let dollars = abs(Double(balance) / 100.0)
        let formatted = String(format: "$%.2f", dollars)
        return balance < 0 ? "-\(formatted)" : formatted
    }

    private var balanceColor: Color {
        if balance < 0 {
            return Theme.Colors.error
        } else if balance > 0 {
            return Theme.Colors.success
        }
        return .primary
    }

    private var balanceMessage: String {
        if balance < 0 {
            return "You owe"
        } else if balance > 0 {
            return "You are owed"
        }
        return "All settled up!"
    }
}

struct DuesCard: View {
    let dues: MockDues

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Text(dues.name)
                    .font(Theme.Typography.headline)

                Spacer()

                Text(dues.formattedAmount)
                    .font(Theme.Typography.headline)
            }

            Text("Due \(dues.dueDate.shortDateString)")
                .font(Theme.Typography.caption)
                .foregroundStyle(.secondary)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.Colors.tertiaryBackground)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.Colors.success)
                        .frame(width: geo.size.width * dues.paidPercentage)
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(dues.paidCount)/\(dues.totalCount) paid")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if dues.isPaid {
                    Label("Paid", systemImage: "checkmark.circle.fill")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.success)
                } else {
                    Label("Unpaid", systemImage: "exclamationmark.circle.fill")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.warning)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
    }
}

struct TransactionRow: View {
    let transaction: LocalTransaction
    let currentUserId: UUID

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Category icon
            Image(systemName: transaction.category.icon)
                .font(.title2)
                .foregroundStyle(Theme.Colors.primary)
                .frame(width: 40, height: 40)
                .background(Theme.Colors.primary.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(transaction.descriptionText)
                    .font(Theme.Typography.headline)

                Text("Paid by \(transaction.paidByName)")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: Theme.Spacing.xxs) {
                Text(transaction.formattedAmount)
                    .font(Theme.Typography.headline)

                if let userSplit = transaction.splits.first(where: { $0.userId == currentUserId }) {
                    Text("Your share: \(userSplit.formattedAmount)")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
    }
}

// Mock dues for preview
struct MockDues {
    let name: String
    let amount: Int
    let dueDate: Date
    let paidCount: Int
    let totalCount: Int
    let isPaid: Bool

    var formattedAmount: String {
        String(format: "$%.2f", Double(amount) / 100.0)
    }

    var paidPercentage: Double {
        Double(paidCount) / Double(totalCount)
    }
}

#Preview {
    NavigationStack {
        FinancesView()
    }
    .environment(AppState())
}
