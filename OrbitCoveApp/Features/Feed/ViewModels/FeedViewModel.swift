import SwiftUI

@Observable
final class FeedViewModel {
    var posts: [LocalPost] = []
    var isLoading = false
    var error: Error?

    var pinnedPosts: [LocalPost] {
        posts.filter { $0.isPinned }
    }

    var regularPosts: [LocalPost] {
        posts.filter { !$0.isPinned }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func loadPosts() async {
        isLoading = true
        error = nil

        do {
            try await Task.sleep(for: .milliseconds(500))
            posts = MockData.postsWithComments
        } catch {
            self.error = error
        }

        isLoading = false
    }

    func addReaction(_ reaction: ReactionType, to post: LocalPost) async {
        // Update locally first (optimistic update)
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            var counts = posts[index].reactionCounts
            counts[reaction.rawValue, default: 0] += 1
            posts[index].reactionCounts = counts
        }

        // Sync with server
        try? await Task.sleep(for: .milliseconds(200))
    }

    func removeReaction(from post: LocalPost) async {
        // Implementation
    }
}
