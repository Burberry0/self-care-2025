import Foundation

struct Achievement: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let requiredProgress: Double
    let currentProgress: Double
    let isUnlocked: Bool
    let dateUnlocked: Date?
    
    var progress: Double {
        min(currentProgress / requiredProgress, 1.0)
    }
    
    init(id: UUID = UUID(), 
         title: String, 
         description: String, 
         icon: String, 
         category: AchievementCategory,
         requiredProgress: Double,
         currentProgress: Double = 0,
         isUnlocked: Bool = false,
         dateUnlocked: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.category = category
        self.requiredProgress = requiredProgress
        self.currentProgress = currentProgress
        self.isUnlocked = isUnlocked
        self.dateUnlocked = dateUnlocked
    }
}

enum AchievementCategory: String, Codable, CaseIterable {
    case mood = "Mood"
    case habits = "Habits"
    case consistency = "Consistency"
    case milestones = "Milestones"
}

class AchievementStore: ObservableObject {
    @Published var achievements: [Achievement] = []
    
    init() {
        loadDefaultAchievements()
    }
    
    private func loadDefaultAchievements() {
        achievements = [
            Achievement(
                title: "Mood Master",
                description: "Track your mood for 7 days in a row",
                icon: "face.smiling.fill",
                category: .mood,
                requiredProgress: 7
            ),
            Achievement(
                title: "Habit Hero",
                description: "Complete 5 habits in one day",
                icon: "checkmark.circle.fill",
                category: .habits,
                requiredProgress: 5
            ),
            Achievement(
                title: "Consistency King",
                description: "Maintain a 30-day streak",
                icon: "flame.fill",
                category: .consistency,
                requiredProgress: 30
            ),
            Achievement(
                title: "Early Bird",
                description: "Complete morning habits for 7 days",
                icon: "sunrise.fill",
                category: .milestones,
                requiredProgress: 7
            ),
            Achievement(
                title: "Night Owl",
                description: "Complete evening habits for 7 days",
                icon: "moon.stars.fill",
                category: .milestones,
                requiredProgress: 7
            ),
            Achievement(
                title: "Mood Analyst",
                description: "Identify a mood pattern",
                icon: "chart.bar.fill",
                category: .mood,
                requiredProgress: 1
            ),
            Achievement(
                title: "Habit Builder",
                description: "Create 5 habits",
                icon: "plus.circle.fill",
                category: .habits,
                requiredProgress: 5
            ),
            Achievement(
                title: "Streak Master",
                description: "Maintain a 100-day streak",
                icon: "flame.fill",
                category: .consistency,
                requiredProgress: 100
            )
        ]
    }
    
    func updateAchievementProgress(achievementId: UUID, currentProgress: Double) {
        if let index = achievements.firstIndex(where: { $0.id == achievementId }) {
            var achievement = achievements[index]
            let newProgress = min(currentProgress, achievement.requiredProgress)
            let isUnlocked = newProgress >= achievement.requiredProgress
            
            achievement = Achievement(
                id: achievement.id,
                title: achievement.title,
                description: achievement.description,
                icon: achievement.icon,
                category: achievement.category,
                requiredProgress: achievement.requiredProgress,
                currentProgress: newProgress,
                isUnlocked: isUnlocked,
                dateUnlocked: isUnlocked && !achievement.isUnlocked ? Date() : achievement.dateUnlocked
            )
            
            achievements[index] = achievement
        }
    }
} 