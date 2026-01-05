import SwiftUI

struct CreateCommunityView: View {
    @Bindable var viewModel: OnboardingViewModel
    @FocusState private var isNameFocused: Bool

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            // Name input
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("What's your community called?")
                    .font(Theme.Typography.headline)

                TextField("e.g., Johnson Family", text: $viewModel.communityName)
                    .textFieldStyle(.plain)
                    .inputFieldStyle()
                    .focused($isNameFocused)
            }

            // Type selection
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text("What type of group is this?")
                    .font(Theme.Typography.headline)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: Theme.Spacing.md) {
                    ForEach(CommunityType.allCases, id: \.self) { type in
                        CommunityTypeCard(
                            type: type,
                            isSelected: viewModel.communityType == type
                        ) {
                            viewModel.communityType = type
                        }
                    }
                }

                Text("This helps us customize your experience. You can change it later.")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Create button
            Button("Create") {
                Task {
                    await viewModel.createCommunity()
                }
            }
            .buttonStyle(.primary)
            .disabled(viewModel.communityName.isEmpty || viewModel.isLoading)

            if viewModel.isLoading {
                ProgressView()
            }
        }
        .padding(Theme.Spacing.lg)
        .background(Theme.Colors.background)
        .navigationTitle("Create Your Community")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isNameFocused = true
        }
    }
}

struct CommunityTypeCard: View {
    let type: CommunityType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.sm) {
                Image(systemName: type.icon)
                    .font(.system(size: 32))

                Text(type.displayName)
                    .font(Theme.Typography.subheadline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.lg)
            .background(isSelected ? Theme.Colors.primary.opacity(0.1) : Theme.Colors.secondaryBackground)
            .foregroundStyle(isSelected ? Theme.Colors.primary : .primary)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                    .stroke(isSelected ? Theme.Colors.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        CreateCommunityView(viewModel: OnboardingViewModel())
    }
}
