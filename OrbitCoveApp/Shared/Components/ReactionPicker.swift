import SwiftUI

struct ReactionPicker: View {
    let onSelect: (ReactionType) -> Void

    var body: some View {
        HStack(spacing: Theme.Spacing.lg) {
            ForEach(ReactionType.allCases, id: \.self) { reaction in
                Button {
                    onSelect(reaction)
                } label: {
                    Text(reaction.emoji)
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Theme.Spacing.md)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(radius: 8)
    }
}

struct ReactionSummary: View {
    let reactionCounts: [String: Int]
    var showCount: Bool = true

    var body: some View {
        if !reactionCounts.isEmpty {
            HStack(spacing: Theme.Spacing.xs) {
                ForEach(sortedReactions, id: \.0) { reaction, count in
                    HStack(spacing: Theme.Spacing.xxs) {
                        if let reactionType = ReactionType(rawValue: reaction) {
                            Text(reactionType.emoji)
                                .font(.caption)
                        }

                        if showCount && count > 1 {
                            Text("\(count)")
                                .font(Theme.Typography.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if showCount {
                    Text("\(totalCount)")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var sortedReactions: [(String, Int)] {
        reactionCounts.sorted { $0.value > $1.value }
    }

    private var totalCount: Int {
        reactionCounts.values.reduce(0, +)
    }
}

#Preview("Reaction Picker") {
    ReactionPicker { reaction in
        // Handle reaction
    }
}

#Preview("Reaction Summary") {
    ReactionSummary(reactionCounts: ["like": 5, "love": 2, "laugh": 1])
}
