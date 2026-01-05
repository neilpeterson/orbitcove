import SwiftUI
import AuthenticationServices

struct WelcomeView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: Theme.Spacing.xxl) {
            Spacer()

            // Logo and tagline
            VStack(spacing: Theme.Spacing.lg) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Theme.Colors.primary)

                Text("OrbitCove")
                    .font(.system(size: 36, weight: .bold))

                Text("Your community, organized.")
                    .font(Theme.Typography.title3)
                    .foregroundStyle(.secondary)
            }

            // Description
            Text("One place for your family, team, or group to coordinate calendars, share updates, and manage expenses.")
                .font(Theme.Typography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)

            Spacer()

            // Sign in button
            VStack(spacing: Theme.Spacing.md) {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    Task {
                        await viewModel.signInWithApple()
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))

                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, Theme.Spacing.sm)
                }
            }
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.bottom, Theme.Spacing.xxl)
        }
        .background(Theme.Colors.background)
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }
}

#Preview {
    NavigationStack {
        WelcomeView(viewModel: OnboardingViewModel())
    }
}
