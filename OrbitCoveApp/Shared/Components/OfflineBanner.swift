import SwiftUI

struct OfflineBanner: View {
    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "wifi.slash")
                .font(.caption)

            Text("You're offline. Changes will sync when you're back online.")
                .font(Theme.Typography.caption)

            Spacer()
        }
        .foregroundStyle(.white)
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
        .background(Theme.Colors.warning)
    }
}

struct SyncIndicator: View {
    var isSyncing: Bool

    var body: some View {
        if isSyncing {
            HStack(spacing: Theme.Spacing.xs) {
                ProgressView()
                    .scaleEffect(0.7)

                Text("Syncing...")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct PendingSyncBadge: View {
    var body: some View {
        HStack(spacing: Theme.Spacing.xxs) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.caption2)

            Text("Pending")
                .font(Theme.Typography.caption2)
        }
        .foregroundStyle(Theme.Colors.warning)
    }
}

#Preview("Offline Banner") {
    VStack {
        OfflineBanner()
        Spacer()
    }
}

#Preview("Sync Indicator") {
    SyncIndicator(isSyncing: true)
}
