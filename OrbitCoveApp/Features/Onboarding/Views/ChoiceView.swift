import SwiftUI

struct ChoiceView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: Theme.Spacing.xxl) {
            Spacer()

            // Header
            VStack(spacing: Theme.Spacing.md) {
                Text("What brings you here?")
                    .font(Theme.Typography.title)
                    .fontWeight(.bold)

                Text("Choose how you'd like to get started")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Options
            VStack(spacing: Theme.Spacing.lg) {
                ChoiceCard(
                    icon: "plus.circle.fill",
                    title: "Create a Community",
                    description: "Start a new space for your family, team, or group"
                ) {
                    viewModel.navigationPath.append(OnboardingStep.createCommunity)
                }

                ChoiceCard(
                    icon: "link.circle.fill",
                    title: "Join a Community",
                    description: "Got an invite code? Enter it to join"
                ) {
                    viewModel.navigationPath.append(OnboardingStep.joinCommunity)
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)

            Spacer()
        }
        .background(Theme.Colors.background)
        .navigationTitle("Get Started")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChoiceCard: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.lg) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.Colors.primary)

                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(title)
                        .font(Theme.Typography.headline)

                    Text(description)
                        .font(Theme.Typography.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
            .padding(Theme.Spacing.lg)
            .background(Theme.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ChoiceView(viewModel: OnboardingViewModel())
    }
}
