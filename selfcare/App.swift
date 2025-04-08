import SwiftUI
import SelfCareKit

// Core
import Core.AppState

// Stores
import Habits.HabitStore
import Mood.MoodStore
import Recommendations.RecommendationStore

@main
struct SelfCareApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var habitStore = HabitStore()
    @StateObject private var moodStore = MoodStore()
    @StateObject private var recommendationStore = RecommendationStore()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                HabitsView()
                    .tabItem {
                        Label("Habits", systemImage: "checkmark.circle.fill")
                    }
                
                ReportsView()
                    .tabItem {
                        Label("Reports", systemImage: "chart.bar.fill")
                    }
                
                RecommendationsView()
                    .tabItem {
                        Label("Recommendations", systemImage: "sparkles")
                    }
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
            }
            .environmentObject(appState)
            .environmentObject(habitStore)
            .environmentObject(moodStore)
            .environmentObject(recommendationStore)
        }
    }
    
    init() {
        // Add initial recommendations
        let recommendations = [
            Recommendation(
                title: "Morning Meditation",
                description: "Start your day with a 10-minute guided meditation",
                type: .meditation,
                category: .mindfulness,
                timeRange: .morning,
                duration: 10
            ),
            Recommendation(
                title: "Evening Journaling",
                description: "Reflect on your day with a 15-minute journaling session",
                type: .journaling,
                category: .mindfulness,
                timeRange: .evening,
                duration: 15
            ),
            Recommendation(
                title: "Lunchtime Walk",
                description: "Take a 20-minute walk during your lunch break",
                type: .exercise,
                category: .fitness,
                timeRange: .afternoon,
                duration: 20
            )
        ]
        
        recommendations.forEach { recommendationStore.addRecommendation($0) }
    }
} 