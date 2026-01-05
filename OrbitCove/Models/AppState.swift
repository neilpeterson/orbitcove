//
//  AppState.swift
//  OrbitCove
//
//  Manages global application state
//

import Foundation
import Combine

class AppState: ObservableObject {
    @Published var communities: [Community] = []
    @Published var currentUser: User?
    
    init() {
        // Initialize with sample data for demonstration
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Sample communities
        communities = [
            Community(
                id: UUID(),
                name: "Family Circle",
                description: "Our private family space",
                type: .family,
                memberCount: 5,
                createdDate: Date()
            ),
            Community(
                id: UUID(),
                name: "Soccer Team",
                description: "U12 Lightning Soccer",
                type: .sports,
                memberCount: 15,
                createdDate: Date()
            ),
            Community(
                id: UUID(),
                name: "Book Club",
                description: "Monthly reading group",
                type: .club,
                memberCount: 8,
                createdDate: Date()
            )
        ]
        
        // Sample user
        currentUser = User(
            id: UUID(),
            name: "User",
            email: "user@orbitcove.com"
        )
    }
    
    func addCommunity(_ community: Community) {
        communities.append(community)
    }
    
    func removeCommunity(_ community: Community) {
        communities.removeAll { $0.id == community.id }
    }
}
