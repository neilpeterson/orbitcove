//
//  CommunityDetailView.swift
//  OrbitCove
//
//  Detailed view of a community with organizational tools
//

import SwiftUI

struct CommunityDetailView: View {
    let community: Community
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Community header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: communityIcon(for: community.type))
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text(community.name)
                                .font(.title)
                                .fontWeight(.bold)
                            Text(community.type.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text(community.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Label("\(community.memberCount) members", systemImage: "person.2.fill")
                        Spacer()
                        if community.isPrivate {
                            Label("Private", systemImage: "lock.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Organizational Tools
                VStack(alignment: .leading, spacing: 12) {
                    Text("Organizational Tools")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(community.tools.filter { $0.isEnabled }) { tool in
                            ToolCardView(tool: tool)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
        }
        .navigationTitle(community.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func communityIcon(for type: CommunityType) -> String {
        switch type {
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

struct ToolCardView: View {
    let tool: OrganizationalTool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: tool.icon)
                .font(.system(size: 32))
                .foregroundColor(.blue)
            
            Text(tool.name)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        CommunityDetailView(community: Community(
            name: "Family Circle",
            description: "Our private family space",
            type: .family,
            memberCount: 5,
            createdDate: Date()
        ))
    }
}
