import SwiftUI

struct LoadingView: View {
    var message: String?

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)

            if let message {
                Text(message)
                    .font(Theme.Typography.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }
}

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            ProgressView()
                .scaleEffect(1.5)
                .padding(Theme.Spacing.xxl)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
        }
    }
}

#Preview("Loading View") {
    LoadingView(message: "Loading...")
}

#Preview("Loading Overlay") {
    ZStack {
        Color.blue
        LoadingOverlay()
    }
}
