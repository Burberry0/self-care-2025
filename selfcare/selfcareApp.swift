//
//  selfcareApp.swift
//  selfcare
//
//  Created by Brandon Kohler on 4/1/25.
//

import SwiftUI

@main
struct selfcareApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var habitStore: HabitStore
    
    init() {
        let store = HabitStore()
        // Check if this is the first launch
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            store.addSampleHabits()
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
        _habitStore = StateObject(wrappedValue: store)
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appState)
                .environmentObject(habitStore)
        }
    }
}

class AppState: ObservableObject {
    @Published var currentUser: User?
    @Published var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case mood
        case habits
        case health
        case profile
    }
    
    init() {
        // TODO: Load user data from persistent storage
        // For now, create a sample user
        self.currentUser = User(name: "Sample User", email: "sample@example.com")
    }
}
