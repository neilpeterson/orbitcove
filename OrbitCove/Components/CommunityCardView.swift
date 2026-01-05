//
//  CommunityCardView.swift
//  OrbitCove
//
//  Card component for displaying community in list
//

import SwiftUI

struct CommunityCardView: View {
    let community: Community
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: communityIcon)
                    .font(.system(size: 28))
                    .foregroundColor(.blue)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(community.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(community.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    Label("\(community.memberCount)", systemImage: "person.2.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if community.isPrivate {
                        Label("Private", systemImage: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var communityIcon: String {
        switch community.type {
        case .family:
            return "house.fill"
        case .sports:
            return "sportscourt.fill"
        case .club:
            return "book.fill"
        case .organization:
            return "building.2.fill"
        case .other:
            return "star.fill"
        }
    }
}

#Preview {
    CommunityCardView(community: Community(
        name: "Family Circle",
        description: "Our private family space",
        type: .family,
        memberCount: 5,
        createdDate: Date()
    ))
    .padding()
}
