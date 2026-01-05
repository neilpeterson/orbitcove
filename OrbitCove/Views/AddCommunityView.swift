//
//  AddCommunityView.swift
//  OrbitCove
//
//  View for creating a new community
//

import SwiftUI

struct AddCommunityView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedType: CommunityType = .family
    @State private var isPrivate = true
    @State private var requiresInvitation = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Community Information")) {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                    
                    Picker("Type", selection: $selectedType) {
                        ForEach(CommunityType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Privacy Settings")) {
                    Toggle("Private Community", isOn: $isPrivate)
                    Toggle("Requires Invitation", isOn: $requiresInvitation)
                    
                    if isPrivate {
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.green)
                            Text("Your community is protected with end-to-end privacy")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Button(action: createCommunity) {
                        HStack {
                            Spacer()
                            Text("Create Community")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
            .navigationTitle("New Community")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func createCommunity() {
        let newCommunity = Community(
            name: name,
            description: description,
            type: selectedType,
            memberCount: 1,
            createdDate: Date()
        )
        
        appState.addCommunity(newCommunity)
        dismiss()
    }
}

#Preview {
    AddCommunityView()
        .environmentObject(AppState())
}
