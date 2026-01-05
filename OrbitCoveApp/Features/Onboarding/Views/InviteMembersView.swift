import SwiftUI

struct InviteMembersView: View {
    @Bindable var viewModel: OnboardingViewModel
    @State private var inviteCode = "ABC123"

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            // Success message
            VStack(spacing: Theme.Spacing.md) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Theme.Colors.success)

                Text("Community Created!")
                    .font(Theme.Typography.title2)
                    .fontWeight(.bold)

                if let community = viewModel.currentCommunity {
                    Text(community.name)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, Theme.Spacing.xl)

            // Invite section
            VStack(spacing: Theme.Spacing.lg) {
                Text("Share this code with people you want to join:")
                    .font(Theme.Typography.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                // Code display
                VStack(spacing: Theme.Spacing.md) {
                    Text(inviteCode)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .tracking(4)

                    Button {
                        UIPasteboard.general.string = inviteCode
                    } label: {
                        Label("Copy Code", systemImage: "doc.on.doc")
                    }
                    .buttonStyle(.secondary)
                }
                .padding(Theme.Spacing.xl)
                .background(Theme.Colors.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
            }

            // Share options
            VStack(spacing: Theme.Spacing.md) {
                ShareLink(
                    item: "Join \(viewModel.currentCommunity?.name ?? "my community") on OrbitCove! Use code \(inviteCode) or tap: orbitcove.app/join/\(inviteCode)"
                ) {
                    Label("Share Invite", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.primary)

                Button {
                    // TODO: Show QR code
                } label: {
                    Label("Show QR Code", systemImage: "qrcode")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.secondary)
            }

            Spacer()

            // Skip button
            Button("Continue") {
                viewModel.finishOnboarding()
            }
            .font(Theme.Typography.headline)
            .foregroundStyle(Theme.Colors.primary)
        }
        .padding(Theme.Spacing.lg)
        .background(Theme.Colors.background)
        .navigationTitle("Invite Members")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    let viewModel = OnboardingViewModel()
    viewModel.currentCommunity = MockData.communities[0]

    return NavigationStack {
        InviteMembersView(viewModel: viewModel)
    }
}
