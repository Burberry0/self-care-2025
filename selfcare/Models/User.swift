import Foundation
import SwiftUI

// MARK: - Codable Color
struct CodableColor: Codable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double
    
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
    
    init(color: Color) {
        if let cgColor = color.cgColor {
            let components = cgColor.components ?? [0, 0, 0, 1]
            self.red = Double(components[0])
            self.green = Double(components[1])
            self.blue = Double(components[2])
            self.opacity = Double(components[3])
        } else {
            self.red = 0
            self.green = 0
            self.blue = 0
            self.opacity = 1
        }
    }
    
    init(red: Double, green: Double, blue: Double, opacity: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }
}

// MARK: - Habit
struct Habit: Codable, Identifiable {
    let id: UUID
    var name: String
    var emoji: String
    var color: CodableColor
    var category: Category
    var type: HabitType
    var goalPeriod: String
    var goalValue: Int
    var goalUnit: String
    var taskDays: Set<Int>
    var timeRange: TimeRange
    var remindersEnabled: Bool
    var reminderTimes: [Date]
    var completedDates: Set<Date>
    
    enum CodingKeys: String, CodingKey {
        case id, name, emoji, color, category, type, goalPeriod, goalValue, goalUnit, taskDays, timeRange, remindersEnabled, reminderTimes, completedDates
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        color: Color,
        category: Category,
        type: HabitType,
        goalPeriod: String,
        goalValue: Int,
        goalUnit: String,
        taskDays: Set<Int>,
        timeRange: TimeRange,
        remindersEnabled: Bool,
        reminderTimes: [Date],
        completedDates: Set<Date> = []
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.color = CodableColor(color: color)
        self.category = category
        self.type = type
        self.goalPeriod = goalPeriod
        self.goalValue = goalValue
        self.goalUnit = goalUnit
        self.taskDays = taskDays
        self.timeRange = timeRange
        self.remindersEnabled = remindersEnabled
        self.reminderTimes = reminderTimes
        self.completedDates = completedDates
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        emoji = try container.decode(String.self, forKey: .emoji)
        color = try container.decode(CodableColor.self, forKey: .color)
        category = try container.decode(Category.self, forKey: .category)
        type = try container.decode(HabitType.self, forKey: .type)
        goalPeriod = try container.decode(String.self, forKey: .goalPeriod)
        goalValue = try container.decode(Int.self, forKey: .goalValue)
        goalUnit = try container.decode(String.self, forKey: .goalUnit)
        taskDays = try container.decode(Set<Int>.self, forKey: .taskDays)
        timeRange = try container.decode(TimeRange.self, forKey: .timeRange)
        remindersEnabled = try container.decode(Bool.self, forKey: .remindersEnabled)
        reminderTimes = try container.decode([Date].self, forKey: .reminderTimes)
        completedDates = try container.decode(Set<Date>.self, forKey: .completedDates)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(emoji, forKey: .emoji)
        try container.encode(color, forKey: .color)
        try container.encode(category, forKey: .category)
        try container.encode(type, forKey: .type)
        try container.encode(goalPeriod, forKey: .goalPeriod)
        try container.encode(goalValue, forKey: .goalValue)
        try container.encode(goalUnit, forKey: .goalUnit)
        try container.encode(taskDays, forKey: .taskDays)
        try container.encode(timeRange, forKey: .timeRange)
        try container.encode(remindersEnabled, forKey: .remindersEnabled)
        try container.encode(reminderTimes, forKey: .reminderTimes)
        try container.encode(completedDates, forKey: .completedDates)
    }
    
    func isCompleted() -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return completedDates.contains { date in
            calendar.isDate(date, inSameDayAs: today)
        }
    }
}

enum HabitType: String, Codable, CaseIterable {
    case build = "Build"
    case stop = "Stop"
    case maintain = "Maintain"
}

enum TimeRange: String, Codable, CaseIterable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    case anytime = "Anytime"
}

// MARK: - Category
enum Category: String, CaseIterable, Codable, Hashable {
    case health = "Health"
    case mindfulness = "Mindfulness"
    case productivity = "Productivity"
    case fitness = "Fitness"
    case learning = "Learning"
    case social = "Social"
    
    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .mindfulness: return "brain.head.profile"
        case .productivity: return "clock.fill"
        case .fitness: return "figure.run"
        case .learning: return "book.fill"
        case .social: return "person.2.fill"
        }
    }
}

// MARK: - Frequency
enum Frequency: String, CaseIterable, Codable, Hashable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case custom = "Custom"
}

// MARK: - Activity
enum Activity: String, CaseIterable, Codable, Hashable {
    case exercise = "Exercise"
    case meditation = "Meditation"
    case reading = "Reading"
    case socializing = "Socializing"
    case work = "Work"
    case sleep = "Sleep"
    case eating = "Eating"
    case other = "Other"
    
    var systemImage: String {
        switch self {
        case .exercise: return "figure.run"
        case .meditation: return "sparkles"
        case .reading: return "book.fill"
        case .socializing: return "person.2.fill"
        case .work: return "briefcase.fill"
        case .sleep: return "bed.double.fill"
        case .eating: return "fork.knife"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

struct User: Codable {
    var id: UUID
    var name: String
    var email: String
    var preferences: UserPreferences
    var achievements: [Achievement]
    var totalHabitsCompleted: Int
    var streaks: [UUID: Int]
    var level: Int
    var experience: Int
    
    init(
        id: UUID = UUID(),
        name: String = "",
        email: String = "",
        preferences: UserPreferences = UserPreferences.default,
        achievements: [Achievement] = [],
        totalHabitsCompleted: Int = 0,
        streaks: [UUID: Int] = [:],
        level: Int = 1,
        experience: Int = 0
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.preferences = preferences
        self.achievements = achievements
        self.totalHabitsCompleted = totalHabitsCompleted
        self.streaks = streaks
        self.level = level
        self.experience = experience
    }
    
    // Migration function for existing user data
    static func migrate(from oldUser: User) -> User {
        var newUser = User(
            id: oldUser.id,
            name: oldUser.name,
            email: oldUser.email,
            preferences: UserPreferences.default,
            achievements: oldUser.achievements,
            totalHabitsCompleted: oldUser.totalHabitsCompleted,
            streaks: oldUser.streaks,
            level: oldUser.level,
            experience: oldUser.experience
        )
        
        // Migrate old preferences to new structure
        if let oldPreferences = oldUser.preferences as? [String: Any] {
            // Convert old preferences to new structure
            // This is a placeholder - you'll need to implement the actual conversion
            // based on your old preferences structure
            newUser.preferences = UserPreferences.default
        }
        
        return newUser
    }
}

// Achievement Types
enum AchievementType {
    case streakMilestone(days: Int)
    case habitsCompleted(count: Int)
    case categoryMaster(category: Category)
    case perfectWeek
    case earlyBird
    case nightOwl
    case habitVariety
    
    var title: String {
        switch self {
        case .streakMilestone(let days):
            return "\(days) Day Streak Master"
        case .habitsCompleted(let count):
            return "\(count) Habits Completed"
        case .categoryMaster(let category):
            return "\(category.rawValue) Master"
        case .perfectWeek:
            return "Perfect Week"
        case .earlyBird:
            return "Early Bird"
        case .nightOwl:
            return "Night Owl"
        case .habitVariety:
            return "Habit Variety"
        }
    }
    
    var description: String {
        switch self {
        case .streakMilestone(let days):
            return "Maintain a \(days)-day streak for any habit"
        case .habitsCompleted(let count):
            return "Complete \(count) habits total"
        case .categoryMaster(let category):
            return "Complete 50 habits in the \(category.rawValue) category"
        case .perfectWeek:
            return "Complete all scheduled habits for 7 days straight"
        case .earlyBird:
            return "Complete 5 habits before 9 AM"
        case .nightOwl:
            return "Complete 5 habits after 9 PM"
        case .habitVariety:
            return "Complete habits across all categories"
        }
    }
    
    var icon: String {
        switch self {
        case .streakMilestone:
            return "flame.fill"
        case .habitsCompleted:
            return "checkmark.circle.fill"
        case .categoryMaster:
            return "star.fill"
        case .perfectWeek:
            return "calendar.badge.checkmark"
        case .earlyBird:
            return "sunrise.fill"
        case .nightOwl:
            return "moon.stars.fill"
        case .habitVariety:
            return "square.grid.3x3.fill"
        }
    }
}

enum PrimaryGoal: String, Codable, CaseIterable {
    case stressRelief = "Stress Relief"
    case focus = "Focus"
    case emotionalResilience = "Emotional Resilience"
    case betterSleep = "Better Sleep"
    case improvingHabits = "Improving Habits"
}

enum TypicalMood: String, Codable, CaseIterable {
    case mostlyPositive = "Mostly Positive"
    case upAndDown = "Up and Down"
    case frequentlyStressed = "Frequently Stressed"
    case frequentlyAnxious = "Frequently Anxious"
}

enum Emotion: String, Codable, CaseIterable {
    case anxiety = "Anxiety"
    case sadness = "Sadness"
    case overwhelm = "Overwhelm"
    case frustration = "Frustration"
    case lackOfMotivation = "Lack of Motivation"
}

enum SelfCareActivity: String, Codable, CaseIterable {
    case meditation = "Meditation"
    case deepBreathing = "Deep Breathing"
    case journaling = "Journaling"
    case walking = "Walking"
    case reading = "Reading"
    case music = "Listening to Music"
    case socializing = "Socializing"
    case creative = "Creative Activities"
}

enum ActivityType: String, Codable, CaseIterable {
    case active = "Active"
    case reflective = "Reflective"
    case social = "Social"
    case passive = "Passive"
}

enum TimeOfDay: String, Codable, CaseIterable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    case beforeBed = "Before Bed"
}

enum ExerciseFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case sometimes = "Sometimes (a few times a week)"
    case rarely = "Rarely/Never"
}

enum DietRating: String, Codable, CaseIterable {
    case healthy = "Healthy"
    case balanced = "Balanced"
    case unhealthy = "Unhealthy"
    case needsImprovement = "Needs Improvement"
} 