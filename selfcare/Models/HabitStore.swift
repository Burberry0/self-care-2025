import Foundation
import SwiftUI

class HabitStore: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var todaysHabits: [Habit] = []
    @Published var user: User
    @Published var recentActivities: [ActivityItem] = []
    @Published var showingCelebration = false
    @Published var celebrationData: (title: String, message: String, icon: String)?
    
    private let habitsKey = "user_habits"
    private let userKey = "user_data"
    private let activitiesKey = "recent_activities"
    private let maxRecentActivities = 50
    
    init() {
        // Load user data or create new user
        if let userData = UserDefaults.standard.data(forKey: userKey),
           let decodedUser = try? JSONDecoder().decode(User.self, from: userData) {
            self.user = decodedUser
        } else {
            self.user = User(
                name: "User",
                email: "user@example.com",
                preferences: UserPreferences.default
            )
        }
        
        // Load activities
        if let activitiesData = UserDefaults.standard.data(forKey: activitiesKey),
           let decodedActivities = try? JSONDecoder().decode([ActivityItem].self, from: activitiesData) {
            self.recentActivities = decodedActivities
        }
        
        loadHabits()
    }
    
    private func saveUser() {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
        }
    }
    
    private func saveActivities() {
        if let encoded = try? JSONEncoder().encode(recentActivities) {
            UserDefaults.standard.set(encoded, forKey: activitiesKey)
        }
    }
    
    private func addActivity(_ activity: ActivityItem) {
        recentActivities.insert(activity, at: 0)
        if recentActivities.count > maxRecentActivities {
            recentActivities.removeLast()
        }
        saveActivities()
    }
    
    private func showCelebration(title: String, message: String, icon: String) {
        celebrationData = (title: title, message: message, icon: icon)
        showingCelebration = true
    }
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        updateTodaysHabits()
        saveHabits()
    }
    
    func toggleHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            // Check if the habit is already completed today
            let isCompletedToday = habits[index].completedDates.contains { date in
                calendar.isDate(date, inSameDayAs: today)
            }
            
            // Silently return if already completed today
            if isCompletedToday {
                return
            }
            
            // Only proceed if the habit wasn't completed today
            habits[index].completedDates.insert(today)
            updateStreak(for: habit)
            user.totalHabitsCompleted += 1
            
            // Add activity
            addActivity(ActivityItem(
                title: "Habit Completed",
                subtitle: habit.name,
                date: Date(),
                icon: "checkmark.circle.fill"
            ))
            
            // Award base experience
            awardExperience(ExperiencePoints.habitCompletion)
            
            // Award streak bonus
            if let streak = user.streaks[habit.id], streak > 1 {
                let bonus = ExperiencePoints.streakBonus * min(streak, 10)
                awardExperience(bonus)
                
                if streak % 5 == 0 {
                    addActivity(ActivityItem(
                        title: "Streak Milestone",
                        subtitle: "\(streak) day streak for \(habit.name)",
                        date: Date(),
                        icon: "flame.fill"
                    ))
                }
            }
            
            // Check for achievements
            checkAchievements()
            
            saveHabits()
            saveUser()
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll(where: { $0.id == habit.id })
        updateTodaysHabits()
        saveHabits()
    }
    
    private func updateTodaysHabits() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        
        todaysHabits = habits.filter { habit in
            habit.taskDays.contains(weekday)
        }
    }
    
    private func saveHabits() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(habits)
            UserDefaults.standard.set(data, forKey: habitsKey)
        } catch {
            print("Error saving habits: \(error)")
        }
    }
    
    private func loadHabits() {
        guard let data = UserDefaults.standard.data(forKey: habitsKey) else {
            // No saved habits found, initialize with empty array
            habits = []
            updateTodaysHabits()
            return
        }
        
        do {
            let decoder = JSONDecoder()
            habits = try decoder.decode([Habit].self, from: data)
            updateTodaysHabits()
        } catch {
            print("Error loading habits: \(error)")
            habits = []
            updateTodaysHabits()
        }
    }
    
    // MARK: - Sample Data
    func addSampleHabits() {
        let sampleHabits: [Habit] = [
            Habit(
                name: "Morning Meditation",
                emoji: "🧘‍♂️",
                color: .blue,
                category: .mindfulness,
                type: .build,
                goalPeriod: "Daily",
                goalValue: 1,
                goalUnit: "session",
                taskDays: Set(1...7),
                timeRange: .morning,
                remindersEnabled: true,
                reminderTimes: [Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()]
            ),
            Habit(
                name: "Evening Walk",
                emoji: "🚶‍♂️",
                color: .green,
                category: .fitness,
                type: .build,
                goalPeriod: "Daily",
                goalValue: 30,
                goalUnit: "minutes",
                taskDays: Set(1...7),
                timeRange: .evening,
                remindersEnabled: true,
                reminderTimes: [Calendar.current.date(from: DateComponents(hour: 18, minute: 0)) ?? Date()]
            ),
            Habit(
                name: "Read a Book",
                emoji: "📚",
                color: .orange,
                category: .learning,
                type: .build,
                goalPeriod: "Daily",
                goalValue: 20,
                goalUnit: "pages",
                taskDays: Set(1...7),
                timeRange: .evening,
                remindersEnabled: true,
                reminderTimes: [Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date()]
            )
        ]
        
        for habit in sampleHabits {
            addHabit(habit)
        }
    }
    
    // Experience points for different actions
    private enum ExperiencePoints {
        static let habitCompletion = 10
        static let streakBonus = 5
        static let perfectDay = 50
        static let achievementUnlock = 100
    }
    
    // Level thresholds
    private func experienceForLevel(_ level: Int) -> Int {
        return level * 100
    }
    
    private func updateStreak(for habit: Habit) {
        if let currentStreak = user.streaks[habit.id] {
            user.streaks[habit.id] = currentStreak + 1
            
            // Check for streak achievements
            checkStreakAchievements(streak: currentStreak + 1)
        } else {
            user.streaks[habit.id] = 1
        }
    }
    
    private func resetStreak(for habit: Habit) {
        user.streaks[habit.id] = 0
    }
    
    private func awardExperience(_ points: Int) {
        user.experience += points
        
        // Check for level up
        let nextLevel = user.level + 1
        let experienceNeeded = nextLevel * 100 // Simplified level calculation
        if user.experience >= experienceNeeded {
            user.level = nextLevel
            
            // Show level up celebration
            showCelebration(
                title: "Level Up!",
                message: "Congratulations! You've reached level \(nextLevel)!",
                icon: "star.circle.fill"
            )
            
            // Add activity
            addActivity(ActivityItem(
                title: "Level Up!",
                subtitle: "Reached level \(nextLevel)",
                date: Date(),
                icon: "star.circle.fill"
            ))
        }
        
        saveUser()
    }
    
    private func removeExperience(_ points: Int) {
        user.experience = max(0, user.experience - points)
        
        // Check if we need to decrease level
        while user.level > 1 && user.experience < (user.level * 100) {
            user.level -= 1
            
            // Add activity for level decrease
            addActivity(ActivityItem(
                title: "Level Decreased",
                subtitle: "Returned to level \(user.level)",
                date: Date(),
                icon: "arrow.down.circle.fill"
            ))
        }
        
        saveUser()
    }
    
    private func checkAchievements() {
        // Check total habits completed
        let totalMilestones = [10, 50, 100, 500, 1000]
        for milestone in totalMilestones {
            if user.totalHabitsCompleted >= milestone {
                unlockAchievement(.habitsCompleted(count: milestone))
            }
        }
        
        // Check category mastery
        for category in Category.allCases {
            let categoryCount = habits.filter { habit in
                habit.category == category && habit.isCompleted()
            }.count
            if categoryCount >= 50 {
                unlockAchievement(.categoryMaster(category: category))
            }
        }
        
        // Check perfect week
        let calendar = Calendar.current
        let lastWeek = calendar.date(byAdding: .day, value: -7, to: Date())!
        let perfectWeek = habits.allSatisfy { habit in
            habit.completedDates.contains { date in
                calendar.isDate(date, inSameDayAs: lastWeek)
            }
        }
        if perfectWeek {
            unlockAchievement(.perfectWeek)
        }
        
        // Check time-based achievements
        let earlyBirdCount = habits.filter { habit in
            guard let completionDate = habit.completedDates.first else { return false }
            let hour = calendar.component(.hour, from: completionDate)
            return hour < 9
        }.count
        
        if earlyBirdCount >= 5 {
            unlockAchievement(.earlyBird)
        }
        
        let nightOwlCount = habits.filter { habit in
            guard let completionDate = habit.completedDates.first else { return false }
            let hour = calendar.component(.hour, from: completionDate)
            return hour >= 21
        }.count
        
        if nightOwlCount >= 5 {
            unlockAchievement(.nightOwl)
        }
    }
    
    private func unlockAchievement(_ type: AchievementType) {
        let achievement = Achievement(
            title: type.title,
            description: type.description,
            icon: type.icon,
            category: .milestones, // Default category for now
            requiredProgress: 1,
            currentProgress: 1,
            isUnlocked: true,
            dateUnlocked: Date()
        )
        
        if !user.achievements.contains(where: { $0.title == achievement.title }) {
            user.achievements.append(achievement)
            awardExperience(ExperiencePoints.achievementUnlock)
            
            // Show achievement celebration
            showCelebration(
                title: "Achievement Unlocked!",
                message: achievement.description,
                icon: achievement.icon
            )
            
            // Add activity
            addActivity(ActivityItem(
                title: "Achievement Unlocked",
                subtitle: achievement.title,
                date: Date(),
                icon: achievement.icon
            ))
            
            saveUser()
        }
    }
    
    private func checkStreakAchievements(streak: Int) {
        let streakMilestones = [7, 30, 100, 365]
        for milestone in streakMilestones {
            if streak >= milestone {
                unlockAchievement(.streakMilestone(days: milestone))
            }
        }
    }
    
    // Reporting properties
    var habitCompletionRates: [HabitCompletionRate] {
        habits.map { habit in
            let completedCount = habit.completedDates.count
            let startDate = habit.completedDates.min() ?? Date()
            let totalDays = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 1
            let rate = Double(completedCount) / Double(max(totalDays, 1))
            return HabitCompletionRate(habitName: habit.name, rate: rate)
        }
    }
    
    var overallCompletionRate: Int {
        guard !habits.isEmpty else { return 0 }
        let totalRate = habitCompletionRates.reduce(0.0) { $0 + $1.rate }
        return Int((totalRate / Double(habits.count)) * 100)
    }
    
    var longestStreak: Int {
        return user.streaks.values.max() ?? 0
    }
    
    var mostConsistentHabit: String {
        guard let mostConsistent = habitCompletionRates.max(by: { $0.rate < $1.rate }) else {
            return "N/A"
        }
        return mostConsistent.habitName
    }
    
    func getHabitCompletionData(for timeRange: ReportsView.TimeRange) -> [HabitCompletionData] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let startDate: Date
        switch timeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: today)!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: today)!
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: today)!
        }
        
        return habits.map { habit in
            let completedDates = habit.completedDates.filter { $0 >= startDate }
            return HabitCompletionData(
                habitName: habit.name,
                completedDates: completedDates
            )
        }
    }
}

struct HabitCompletionRate: Identifiable {
    let id = UUID()
    let habitName: String
    let rate: Double
}

struct HabitCompletionData: Identifiable {
    let id = UUID()
    let habitName: String
    let completedDates: Set<Date>
} 
