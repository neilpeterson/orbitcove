import SwiftUI

struct ErrorView: View {
    let error: Error
    var retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(Theme.Colors.error)

            Text("Something went wrong")
                .font(Theme.Typography.headline)

            Text(error.localizedDescription)
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)

            if let retryAction {
                Button("Try Again", action: retryAction)
                    .buttonStyle(.primary)
                    .padding(.horizontal, Theme.Spacing.xxl)
                    .padding(.top, Theme.Spacing.md)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }
}

struct ErrorBanner: View {
    let message: String
    var dismissAction: (() -> Void)?

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(Theme.Colors.error)

            Text(message)
                .font(Theme.Typography.subheadline)

            Spacer()

            if let dismissAction {
                Button(action: dismissAction) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.error.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
    }
}

#Preview("Error View") {
    ErrorView(error: ServiceError.networkError) {
        // Retry action
    }
}

#Preview("Error Banner") {
    ErrorBanner(message: "Unable to connect to the server") {
        // Dismiss action
    }
    .padding()
}
