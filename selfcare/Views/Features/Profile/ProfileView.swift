import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var habitStore: HabitStore
    @Environment(\.colorScheme) var colorScheme
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Level and Experience
                    VStack {
                        Text("Level \(habitStore.user.level)")
                            .font(.system(size: 34, weight: .bold))
                        
                        // Experience Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.secondary.opacity(0.2))
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.accentColor)
                                    .frame(width: geometry.size.width * CGFloat(habitStore.user.experience % 100) / 100, height: 8)
                            }
                        }
                        .frame(height: 8)
                        .padding(.horizontal)
                        
                        Text("\(habitStore.user.experience) XP")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    // Stats
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatCard(title: "Total Habits", value: "\(habitStore.user.totalHabitsCompleted)", icon: "checkmark.circle.fill")
                        StatCard(title: "Best Streak", value: "\(bestStreak)", icon: "flame.fill")
                        StatCard(title: "Achievements", value: "\(habitStore.user.achievements.count)", icon: "star.fill")
                    }
                    .padding(.horizontal)
                    
                    // Achievements
                    VStack(alignment: .leading) {
                        Text("Achievements")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(habitStore.user.achievements) { achievement in
                                    AchievementCard(achievement: achievement, style: .compact)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Recent Activity
                    if !habitStore.recentActivities.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Recent Activity")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ForEach(habitStore.recentActivities.prefix(10)) { activity in
                                ActivityRow(activity: activity)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                            .font(.system(size: 20, weight: .semibold))
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .background(Color(.systemGroupedBackground))
            .overlay {
                if habitStore.showingCelebration, let celebration = habitStore.celebrationData {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .overlay {
                            ZStack {
                                CelebrationView(
                                    title: celebration.title,
                                    message: celebration.message,
                                    icon: celebration.icon,
                                    isPresented: $habitStore.showingCelebration
                                )
                                
                                ConfettiView()
                                    .allowsHitTesting(false)
                            }
                        }
                        .transition(.opacity)
                }
            }
        }
    }
    
    private var bestStreak: Int {
        habitStore.user.streaks.values.max() ?? 0
    }
}

struct ActivityRow: View {
    let activity: ActivityItem
    
    var body: some View {
        HStack {
            Image(systemName: activity.icon)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading) {
                Text(activity.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(activity.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(activity.date.formatted(.relative(presentation: .named)))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    ProfileView()
        .environmentObject(HabitStore())
} 