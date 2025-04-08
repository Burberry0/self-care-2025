import Foundation
import SwiftUI

class PersonalizationInsightsViewModel: ObservableObject {
    @Published var personalizationStore: PersonalizationStore
    @Published var moodStore: MoodStore
    
    init(personalizationStore: PersonalizationStore, moodStore: MoodStore) {
        self.personalizationStore = personalizationStore
        self.moodStore = moodStore
    }
    
    // Activity Insights
    var activityEngagement: [(String, Double)] {
        personalizationStore.preferences.activityEngagement
            .map { ($0.key, $0.value) }
            .sorted { $0.1 > $1.1 }
    }
    
    // Mood Insights
    var moodBaseline: Double {
        personalizationStore.preferences.moodBaseline
    }
    
    var moodChanges: [PersonalizationStore.MoodChange] {
        personalizationStore.detectMoodChanges()
    }
    
    // Learning Preferences
    var preferredContentTypes: Set<UserPreferences.LearningPreferences.ContentType> {
        personalizationStore.preferences.learningPreferences.preferredContentTypes
    }
    
    var learningStyle: UserPreferences.LearningPreferences.LearningStyle {
        personalizationStore.preferences.learningPreferences.learningStyle
    }
    
    var difficultyLevel: UserPreferences.LearningPreferences.DifficultyLevel {
        personalizationStore.preferences.learningPreferences.difficultyLevel
    }
    
    // Formatted values for display
    var formattedLearningStyle: String {
        learningStyle.rawValue
    }
    
    var formattedDifficultyLevel: String {
        switch difficultyLevel {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }
    
    // Notification Insights
    var preferredNotificationTypes: Set<UserPreferences.NotificationPreferences.NotificationType> {
        personalizationStore.preferences.notificationPreferences.preferredNotificationTypes
    }
    
    var quietHours: UserPreferences.NotificationPreferences.QuietHours {
        personalizationStore.preferences.notificationPreferences.quietHours
    }
    
    var notificationResponseRate: Double {
        let totalNotifications = Double(personalizationStore.notificationHistory.count)
        guard totalNotifications > 0 else { return 0 }
        return Double(personalizationStore.notificationHistory.filter { $0.wasOpened }.count) / totalNotifications
    }
    
    func getOptimalTimeForActivity(_ activity: String) -> Date? {
        personalizationStore.getOptimalTimeForActivity(activity)
    }
} 