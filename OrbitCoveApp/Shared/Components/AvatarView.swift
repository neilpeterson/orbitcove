import SwiftUI

struct AvatarView: View {
    let name: String
    var imageUrl: String?
    var size: CGFloat = 40

    var body: some View {
        Group {
            if let imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var placeholder: some View {
        ZStack {
            Circle()
                .fill(avatarColor)

            Text(initials)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private var initials: String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        } else if let first = components.first {
            return String(first.prefix(2)).uppercased()
        }
        return "?"
    }

    private var avatarColor: Color {
        let colors: [Color] = [
            .blue, .purple, .pink, .red, .orange, .yellow, .green, .teal, .cyan, .indigo
        ]
        let hash = abs(name.hashValue)
        return colors[hash % colors.count]
    }
}

struct CommunityAvatarView: View {
    let name: String
    var iconUrl: String?
    var communityType: CommunityType = .other
    var size: CGFloat = 40

    var body: some View {
        Group {
            if let iconUrl, let url = URL(string: iconUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.2))
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.2)
                .fill(avatarColor)

            Image(systemName: communityType.icon)
                .font(.system(size: size * 0.45))
                .foregroundStyle(.white)
        }
    }

    private var avatarColor: Color {
        switch communityType {
        case .family: return .purple
        case .team: return .blue
        case .club: return .green
        case .other: return .gray
        }
    }
}

#Preview("User Avatars") {
    VStack(spacing: 20) {
        AvatarView(name: "Sarah Johnson")
        AvatarView(name: "Coach Dan", size: 60)
        AvatarView(name: "Mike")
    }
}

#Preview("Community Avatars") {
    VStack(spacing: 20) {
        CommunityAvatarView(name: "Johnson Family", communityType: .family)
        CommunityAvatarView(name: "Tigers LL", communityType: .team, size: 60)
        CommunityAvatarView(name: "Book Club", communityType: .club)
    }
}
