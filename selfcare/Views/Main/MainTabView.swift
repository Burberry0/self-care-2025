import SwiftUI
import Charts

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppState.Tab.home)
            
            MoodView()
                .tabItem {
                    Label("Mood", systemImage: "heart.fill")
                }
                .tag(AppState.Tab.mood)
            
            HabitsView()
                .tabItem {
                    Label("Habits", systemImage: "checkmark.circle.fill")
                }
                .tag(AppState.Tab.habits)
            
            HealthView()
                .tabItem {
                    Label("Health", systemImage: "figure.walk")
                }
                .tag(AppState.Tab.health)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(AppState.Tab.profile)
        }
    }
} 