import Foundation
import SwiftUI

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

// MARK: - Energy Level
enum EnergyLevel: String, CaseIterable, Codable, Hashable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    
    var icon: String {
        switch self {
        case .high: return "bolt.fill"
        case .medium: return "bolt"
        case .low: return "bolt.slash"
        }
    }
}

// MARK: - Mood
enum Mood: String, CaseIterable, Codable, Hashable {
    case veryHappy = "😄"
    case happy = "🙂"
    case neutral = "😐"
    case sad = "😔"
    case verySad = "😢"
    
    var emoji: String {
        return self.rawValue
    }
}

// MARK: - Mood Entry
struct MoodEntry: Codable, Identifiable {
    let id: UUID
    let mood: Mood
    let energy: EnergyLevel
    let activities: Set<Activity>
    let notes: String
    let timestamp: Date
    
    init(id: UUID = UUID(), mood: Mood, energy: EnergyLevel, activities: Set<Activity>, notes: String, timestamp: Date = Date()) {
        self.id = id
        self.mood = mood
        self.energy = energy
        self.activities = activities
        self.notes = notes
        self.timestamp = timestamp
    }
}

// MARK: - Popular Habits
enum PopularHabit: String, CaseIterable, Codable, Hashable {
    case walk = "Walk"
    case run = "Run"
    case stand = "Stand"
    case cycling = "Cycling"
    case workout = "Workout"
    case activeCalorie = "Active Calorie"
    case burnCalorie = "Burn Calorie"
    case exercise = "Exercise"
    case meditation = "Meditation"
    
    var emoji: String {
        switch self {
        case .walk: return "🚶"
        case .run: return "🏃"
        case .stand: return "🧍"
        case .cycling: return "🚴"
        case .workout: return "💪"
        case .activeCalorie, .burnCalorie: return "🔥"
        case .exercise: return "🏃"
        case .meditation: return "🧘"
        }
    }
}

// MARK: - Habit Type
enum HabitType: String, CaseIterable, Codable {
    case build = "Build"
    case quit = "Quit"
}

// MARK: - Time Range
enum TimeRange: String, CaseIterable, Codable, Hashable {
    case anytime = "Anytime"
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
}

// MARK: - Chart Type
enum ChartType: String, CaseIterable, Codable {
    case bar = "Bar"
    case line = "Line"
}

// MARK: - Habit
struct Habit: Identifiable, Codable {
    let id: UUID
    var name: String
    var emoji: String
    var color: Color
    var category: Category
    var group: String?
    var type: HabitType
    var goalPeriod: String
    var goalValue: Int
    var goalUnit: String
    var taskDays: Set<Int> // 1-7 representing days of week
    var timeRange: TimeRange
    var remindersEnabled: Bool
    var reminderTimes: [Date]
    var ringtone: String
    var reminderMessage: String?
    var showMemoAfterCompletion: Bool
    var habitBarGesture: String
    var chartType: ChartType
    var startDate: Date
    var endDate: Date?
    var completedDates: Set<Date> // Track completion dates
    
    init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        color: Color = .blue,
        category: Category = .health,
        group: String? = nil,
        type: HabitType = .build,
        goalPeriod: String = "Day-Long",
        goalValue: Int = 0,
        goalUnit: String = "",
        taskDays: Set<Int> = Set(1...7),
        timeRange: TimeRange = .anytime,
        remindersEnabled: Bool = false,
        reminderTimes: [Date] = [],
        ringtone: String = "Default",
        reminderMessage: String? = nil,
        showMemoAfterCompletion: Bool = false,
        habitBarGesture: String = "Mark as done",
        chartType: ChartType = .bar,
        startDate: Date = Date(),
        endDate: Date? = nil,
        completedDates: Set<Date> = []
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.color = color
        self.category = category
        self.group = group
        self.type = type
        self.goalPeriod = goalPeriod
        self.goalValue = goalValue
        self.goalUnit = goalUnit
        self.taskDays = taskDays
        self.timeRange = timeRange
        self.remindersEnabled = remindersEnabled
        self.reminderTimes = reminderTimes
        self.ringtone = ringtone
        self.reminderMessage = reminderMessage
        self.showMemoAfterCompletion = showMemoAfterCompletion
        self.habitBarGesture = habitBarGesture
        self.chartType = chartType
        self.startDate = startDate
        self.endDate = endDate
        self.completedDates = completedDates
    }
    
    // Helper method to check if habit is completed for a given date
    func isCompleted(on date: Date = Date()) -> Bool {
        let calendar = Calendar.current
        return completedDates.contains { completedDate in
            calendar.isDate(completedDate, inSameDayAs: date)
        }
    }
    
    // Helper method to toggle completion for a given date
    mutating func toggleCompletion(on date: Date = Date()) {
        let calendar = Calendar.current
        if let existingDate = completedDates.first(where: { calendar.isDate($0, inSameDayAs: date) }) {
            completedDates.remove(existingDate)
        } else {
            completedDates.insert(date)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, emoji, color, category, group, type, goalPeriod, goalValue, goalUnit, taskDays
        case timeRange, remindersEnabled, reminderTimes, ringtone, reminderMessage
        case showMemoAfterCompletion, habitBarGesture, chartType, startDate, endDate
        case completedDates
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        emoji = try container.decode(String.self, forKey: .emoji)
        color = try container.decode(Color.self, forKey: .color)
        category = try container.decode(Category.self, forKey: .category)
        group = try container.decodeIfPresent(String.self, forKey: .group)
        type = try container.decode(HabitType.self, forKey: .type)
        goalPeriod = try container.decode(String.self, forKey: .goalPeriod)
        goalValue = try container.decode(Int.self, forKey: .goalValue)
        goalUnit = try container.decode(String.self, forKey: .goalUnit)
        taskDays = try container.decode(Set<Int>.self, forKey: .taskDays)
        timeRange = try container.decode(TimeRange.self, forKey: .timeRange)
        remindersEnabled = try container.decode(Bool.self, forKey: .remindersEnabled)
        reminderTimes = try container.decode([Date].self, forKey: .reminderTimes)
        ringtone = try container.decode(String.self, forKey: .ringtone)
        reminderMessage = try container.decodeIfPresent(String.self, forKey: .reminderMessage)
        showMemoAfterCompletion = try container.decode(Bool.self, forKey: .showMemoAfterCompletion)
        habitBarGesture = try container.decode(String.self, forKey: .habitBarGesture)
        chartType = try container.decode(ChartType.self, forKey: .chartType)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decodeIfPresent(Date.self, forKey: .endDate)
        completedDates = try container.decode(Set<Date>.self, forKey: .completedDates)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(emoji, forKey: .emoji)
        try container.encode(color, forKey: .color)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(group, forKey: .group)
        try container.encode(type, forKey: .type)
        try container.encode(goalPeriod, forKey: .goalPeriod)
        try container.encode(goalValue, forKey: .goalValue)
        try container.encode(goalUnit, forKey: .goalUnit)
        try container.encode(taskDays, forKey: .taskDays)
        try container.encode(timeRange, forKey: .timeRange)
        try container.encode(remindersEnabled, forKey: .remindersEnabled)
        try container.encode(reminderTimes, forKey: .reminderTimes)
        try container.encode(ringtone, forKey: .ringtone)
        try container.encodeIfPresent(reminderMessage, forKey: .reminderMessage)
        try container.encode(showMemoAfterCompletion, forKey: .showMemoAfterCompletion)
        try container.encode(habitBarGesture, forKey: .habitBarGesture)
        try container.encode(chartType, forKey: .chartType)
        try container.encode(startDate, forKey: .startDate)
        try container.encodeIfPresent(endDate, forKey: .endDate)
        try container.encode(completedDates, forKey: .completedDates)
    }
}

// MARK: - Color Codable Extension
extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue, opacity
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let r = try container.decode(Double.self, forKey: .red)
        let g = try container.decode(Double.self, forKey: .green)
        let b = try container.decode(Double.self, forKey: .blue)
        let o = try container.decode(Double.self, forKey: .opacity)
        
        self.init(red: r, green: g, blue: b, opacity: o)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        #if os(iOS)
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &o)
        #else
        NSColor(self).getRed(&r, green: &g, blue: &b, alpha: &o)
        #endif
        
        try container.encode(r, forKey: .red)
        try container.encode(g, forKey: .green)
        try container.encode(b, forKey: .blue)
        try container.encode(o, forKey: .opacity)
    }
} 