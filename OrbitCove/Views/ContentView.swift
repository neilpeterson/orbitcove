//
//  ContentView.swift
//  OrbitCove
//
//  Main view for the app
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAddCommunity = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Header with privacy badge
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("OrbitCove")
                            .font(.system(size: 28, weight: .bold))
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.green)
                            Text("Privacy-First Platform")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding()
                
                // Community list
                if appState.communities.isEmpty {
                    EmptyCommunityView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(appState.communities) { community in
                                NavigationLink(destination: CommunityDetailView(community: community)) {
                                    CommunityCardView(community: community)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddCommunity = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddCommunity) {
                AddCommunityView()
            }
        }
    }
}

struct EmptyCommunityView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            Text("No Communities Yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Create your first private community space")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
