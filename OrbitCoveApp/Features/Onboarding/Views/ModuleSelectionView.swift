import SwiftUI

struct ModuleSelectionView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            // Header
            VStack(spacing: Theme.Spacing.sm) {
                Text("Customize Your Space")
                    .font(Theme.Typography.title2)
                    .fontWeight(.bold)

                Text("Choose which features to enable for \(viewModel.communityName). You can change these later in settings.")
                    .font(Theme.Typography.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Theme.Spacing.lg)

            // Module list
            VStack(spacing: Theme.Spacing.md) {
                ForEach(CommunityModule.allCases) { module in
                    ModuleToggleRow(
                        module: module,
                        isEnabled: viewModel.selectedModules.contains(module),
                        isOnlyEnabled: viewModel.selectedModules.count == 1 && viewModel.selectedModules.contains(module)
                    ) {
                        viewModel.toggleModule(module)
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)

            // Info text
            Text("At least one feature must be enabled")
                .font(Theme.Typography.caption)
                .foregroundStyle(.tertiary)

            Spacer()

            // Continue button
            Button {
                viewModel.confirmModules()
            } label: {
                Text("Continue")
                    .font(Theme.Typography.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.md)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, Theme.Spacing.lg)
        }
        .padding(.vertical, Theme.Spacing.lg)
        .background(Theme.Colors.background)
        .navigationTitle("Features")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ModuleToggleRow: View {
    let module: CommunityModule
    let isEnabled: Bool
    let isOnlyEnabled: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: Theme.Spacing.md) {
                // Icon
                Image(systemName: module.icon)
                    .font(.title2)
                    .foregroundStyle(isEnabled ? Theme.Colors.primary : .secondary)
                    .frame(width: 44, height: 44)
                    .background(isEnabled ? Theme.Colors.primary.opacity(0.1) : Theme.Colors.tertiaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))

                // Text
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(module.displayName)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.primary)

                    Text(module.description)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                // Checkmark
                Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isEnabled ? Theme.Colors.primary : Color.gray.opacity(0.4))
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                    .stroke(isEnabled ? Theme.Colors.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .opacity(isOnlyEnabled ? 0.6 : 1.0)
    }
}

#Preview {
    NavigationStack {
        ModuleSelectionView(viewModel: {
            let vm = OnboardingViewModel()
            vm.communityName = "Test Team"
            vm.communityType = .team
            return vm
        }())
    }
}
