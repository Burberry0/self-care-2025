import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    var name: String
    var email: String
    var preferences: UserPreferences
    var healthData: HealthData
    var moodHistory: [MoodEntry]
    var habits: [Habit]
    
    init(id: UUID = UUID(), name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
        self.preferences = UserPreferences()
        self.healthData = HealthData()
        self.moodHistory = []
        self.habits = []
    }
}

struct UserPreferences: Codable {
    var notificationsEnabled: Bool
    var dailyReminderTime: Date
    var weeklyReportEnabled: Bool
    var privacySettings: PrivacySettings
    
    init() {
        self.notificationsEnabled = true
        self.dailyReminderTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
        self.weeklyReportEnabled = true
        self.privacySettings = PrivacySettings()
    }
}

struct PrivacySettings: Codable {
    var shareHealthData: Bool
    var shareMoodData: Bool
    var shareHabitData: Bool
    
    init() {
        self.shareHealthData = false
        self.shareMoodData = false
        self.shareHabitData = false
    }
} 