import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(.tertiary)

            Text(title)
                .font(Theme.Typography.headline)

            Text(message)
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.primary)
                    .padding(.horizontal, Theme.Spacing.xxl)
                    .padding(.top, Theme.Spacing.md)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }
}

// MARK: - Preset Empty States

extension EmptyStateView {
    static func noEvents(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "calendar",
            title: "No upcoming events",
            message: "Create an event to get your community organized.",
            actionTitle: "Create Event",
            action: action
        )
    }

    static func noPosts(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "newspaper",
            title: "No posts yet",
            message: "Be the first to share an update with your community!",
            actionTitle: "Create Post",
            action: action
        )
    }

    static func noTransactions(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "dollarsign.circle",
            title: "All settled up!",
            message: "No expenses or balances to track yet. Add an expense when your group shares a cost.",
            actionTitle: "Add Expense",
            action: action
        )
    }

    static func noCommunities(createAction: @escaping () -> Void, joinAction: @escaping () -> Void) -> some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "person.3")
                .font(.system(size: 56))
                .foregroundStyle(.tertiary)

            Text("Welcome to OrbitCove!")
                .font(Theme.Typography.headline)

            Text("Create a community for your family, team, or group, or join one you've been invited to.")
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)

            VStack(spacing: Theme.Spacing.md) {
                Button("Create Community", action: createAction)
                    .buttonStyle(.primary)

                Button("Join with Code", action: joinAction)
                    .buttonStyle(.secondary)
            }
            .padding(.horizontal, Theme.Spacing.xxl)
            .padding(.top, Theme.Spacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }
}

#Preview("Empty Events") {
    EmptyStateView.noEvents { }
}

#Preview("Empty Posts") {
    EmptyStateView.noPosts { }
}

#Preview("No Communities") {
    EmptyStateView.noCommunities(createAction: {}, joinAction: {})
}
