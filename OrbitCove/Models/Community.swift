//
//  Community.swift
//  OrbitCove
//
//  Data model for a community/group
//

import Foundation

enum CommunityType: String, Codable, CaseIterable {
    case family = "Family"
    case sports = "Sports Team"
    case club = "Club"
    case organization = "Organization"
    case other = "Other"
}

struct Community: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var type: CommunityType
    var memberCount: Int
    var createdDate: Date
    var tools: [OrganizationalTool] = []
    
    // Privacy settings
    var isPrivate: Bool = true
    var requiresInvitation: Bool = true
    
    init(id: UUID = UUID(), name: String, description: String, type: CommunityType, memberCount: Int, createdDate: Date, isPrivate: Bool = true, requiresInvitation: Bool = true) {
        self.id = id
        self.name = name
        self.description = description
        self.type = type
        self.memberCount = memberCount
        self.createdDate = createdDate
        self.isPrivate = isPrivate
        self.requiresInvitation = requiresInvitation
        
        // Initialize with default organizational tools
        self.tools = [
            OrganizationalTool(name: "Calendar", icon: "calendar", isEnabled: true),
            OrganizationalTool(name: "Messages", icon: "message", isEnabled: true),
            OrganizationalTool(name: "Tasks", icon: "checklist", isEnabled: true),
            OrganizationalTool(name: "Files", icon: "folder", isEnabled: true),
            OrganizationalTool(name: "Events", icon: "calendar.badge.clock", isEnabled: true)
        ]
    }
}

struct OrganizationalTool: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var isEnabled: Bool
    
    init(id: UUID = UUID(), name: String, icon: String, isEnabled: Bool) {
        self.id = id
        self.name = name
        self.icon = icon
        self.isEnabled = isEnabled
    }
}
