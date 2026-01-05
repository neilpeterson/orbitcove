import SwiftUI

struct JoinCommunityView: View {
    @Bindable var viewModel: OnboardingViewModel
    @FocusState private var isCodeFocused: Bool

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            // Instructions
            VStack(spacing: Theme.Spacing.md) {
                Text("Enter the invite code you received:")
                    .font(Theme.Typography.headline)

                TextField("ABC123", text: $viewModel.inviteCode)
                    .textFieldStyle(.plain)
                    .font(.system(size: 24, weight: .medium, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.characters)
                    .inputFieldStyle()
                    .focused($isCodeFocused)
            }

            // Join button
            Button("Join") {
                Task {
                    await viewModel.joinCommunity()
                }
            }
            .buttonStyle(.primary)
            .disabled(viewModel.inviteCode.isEmpty || viewModel.isLoading)

            if viewModel.isLoading {
                ProgressView()
            }

            // Error message
            if let error = viewModel.error {
                ErrorBanner(message: error.localizedDescription) {
                    viewModel.error = nil
                }
            }

            // Divider
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.tertiary)

                Text("or")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)

                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, Theme.Spacing.md)

            // Scan QR
            Button {
                // TODO: Implement QR scanning
            } label: {
                Label("Scan QR Code", systemImage: "qrcode.viewfinder")
            }
            .buttonStyle(.secondary)

            Spacer()

            // Help text
            Text("Don't have a code? Ask your group admin to invite you.")
                .font(Theme.Typography.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)
        }
        .padding(Theme.Spacing.lg)
        .background(Theme.Colors.background)
        .navigationTitle("Join a Community")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isCodeFocused = true
        }
    }
}

#Preview {
    NavigationStack {
        JoinCommunityView(viewModel: OnboardingViewModel())
    }
}
