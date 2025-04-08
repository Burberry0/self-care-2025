import SwiftUI
import Charts

struct ReportsView: View {
    @EnvironmentObject var habitStore: HabitStore
    @EnvironmentObject var moodStore: MoodStore
    @EnvironmentObject var healthStore: HealthStore
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedCategory: ReportCategory = .mood
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    enum ReportCategory: String, CaseIterable {
        case mood = "Mood"
        case habits = "Habits"
        case achievements = "Achievements"
        case health = "Health"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Range Picker
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Category Picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ReportCategory.allCases, id: \.self) { category in
                                CategoryButton(
                                    title: category.rawValue,
                                    systemImage: categoryIcon(for: category),
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Report Content
                    switch selectedCategory {
                    case .mood:
                        MoodReportView(timeRange: selectedTimeRange)
                    case .habits:
                        HabitsReportView(timeRange: selectedTimeRange)
                    case .achievements:
                        AchievementsReportView(timeRange: selectedTimeRange)
                    case .health:
                        HealthReportView(timeRange: selectedTimeRange)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Reports")
        }
    }
    
    private func categoryIcon(for category: ReportCategory) -> String {
        switch category {
        case .mood:
            return "face.smiling.fill"
        case .habits:
            return "checkmark.circle.fill"
        case .achievements:
            return "star.fill"
        case .health:
            return "heart.fill"
        }
    }
}

struct MoodReportView: View {
    @EnvironmentObject var moodStore: MoodStore
    let timeRange: ReportsView.TimeRange
    
    var filteredEntries: [MoodEntry] {
        moodStore.getMoodEntries(for: timeRange)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mood Trends")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            // Mood Chart
            Chart {
                ForEach(filteredEntries) { entry in
                    LineMark(
                        x: .value("Date", entry.timestamp),
                        y: .value("Mood", entry.mood.numericValue)
                    )
                    .foregroundStyle(Color.blue.gradient)
                }
            }
            .frame(height: 200)
            .padding()
            
            // Mood Statistics
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatCard(
                    title: "Average Mood",
                    value: String(format: "%.1f", moodStore.averageMood),
                    icon: "chart.bar.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Best Day",
                    value: moodStore.bestMoodDay?.formatted(.dateTime.weekday()) ?? "N/A",
                    icon: "arrow.up.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Mood Patterns",
                    value: moodStore.mostCommonMood.rawValue,
                    icon: "chart.pie.fill",
                    color: .purple
                )
                
                StatCard(
                    title: "Consistency",
                    value: "\(moodStore.moodTrackingConsistency)%",
                    icon: "checkmark.circle.fill",
                    color: .orange
                )
            }
            .padding(.horizontal)
        }
    }
}

struct HabitsReportView: View {
    @EnvironmentObject var habitStore: HabitStore
    let timeRange: ReportsView.TimeRange
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Habit Progress")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            // Completion Rate Chart
            Chart {
                ForEach(habitStore.habitCompletionRates) { rate in
                    BarMark(
                        x: .value("Habit", rate.habitName),
                        y: .value("Completion", rate.rate)
                    )
                    .foregroundStyle(Color.green.gradient)
                }
            }
            .frame(height: 200)
            .padding()
            
            // Habit Statistics
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatCard(
                    title: "Completion Rate",
                    value: "\(habitStore.overallCompletionRate)%",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Best Streak",
                    value: "\(habitStore.longestStreak) days",
                    icon: "flame.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Total Habits",
                    value: "\(habitStore.habits.count)",
                    icon: "list.bullet",
                    color: .blue
                )
                
                StatCard(
                    title: "Most Consistent",
                    value: habitStore.mostConsistentHabit,
                    icon: "star.fill",
                    color: .yellow
                )
            }
            .padding(.horizontal)
        }
    }
}

struct AchievementsReportView: View {
    @EnvironmentObject var habitStore: HabitStore
    let timeRange: ReportsView.TimeRange
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievement Progress")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            // Achievement Progress Chart
            Chart {
                ForEach(habitStore.user.achievements) { achievement in
                    BarMark(
                        x: .value("Achievement", achievement.title),
                        y: .value("Progress", achievement.progress)
                    )
                    .foregroundStyle(achievement.isUnlocked ? Color.green.gradient : Color.blue.gradient)
                }
            }
            .frame(height: 200)
            .padding()
            
            // Achievement Statistics
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatCard(
                    title: "Total Achievements",
                    value: "\(habitStore.user.achievements.count)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                StatCard(
                    title: "Unlocked",
                    value: "\(habitStore.user.achievements.filter { $0.isUnlocked }.count)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "In Progress",
                    value: "\(habitStore.user.achievements.filter { !$0.isUnlocked }.count)",
                    icon: "clock.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Next Level",
                    value: "\(habitStore.user.level + 1)",
                    icon: "arrow.up.circle.fill",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }
}

struct HealthReportView: View {
    @EnvironmentObject var healthStore: HealthStore
    let timeRange: ReportsView.TimeRange
    
    struct StepData: Identifiable {
        let id = UUID()
        let date: Date
        let steps: Int
    }
    
    var stepData: [StepData] {
        // Sample data - replace with actual health store data
        return [
            StepData(date: Date().addingTimeInterval(-86400), steps: 8000),
            StepData(date: Date().addingTimeInterval(-172800), steps: 7500),
            StepData(date: Date().addingTimeInterval(-259200), steps: 9000)
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Health Trends")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            // Steps Chart
            Chart {
                ForEach(stepData) { data in
                    LineMark(
                        x: .value("Date", data.date),
                        y: .value("Steps", data.steps)
                    )
                    .foregroundStyle(Color.blue.gradient)
                }
            }
            .frame(height: 200)
            .padding()
            
            // Health Statistics
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatCard(
                    title: "Daily Steps",
                    value: "8,234",
                    icon: "figure.walk",
                    color: .blue
                )
                
                StatCard(
                    title: "Active Minutes",
                    value: "45",
                    icon: "flame.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Distance",
                    value: "5.2 km",
                    icon: "figure.walk.motion",
                    color: .green
                )
                
                StatCard(
                    title: "Calories",
                    value: "450",
                    icon: "bolt.heart.fill",
                    color: .red
                )
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ReportsView()
        .environmentObject(HabitStore())
        .environmentObject(MoodStore())
        .environmentObject(HealthStore())
} 