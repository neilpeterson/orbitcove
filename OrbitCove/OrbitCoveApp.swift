//
//  OrbitCoveApp.swift
//  OrbitCove
//
//  Privacy-first, all-in-one community platform for iOS
//

import SwiftUI

@main
struct OrbitCoveApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
