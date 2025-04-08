import Foundation
import SwiftUI

class PersonalizationStore: ObservableObject {
    @Published var preferences: UserPreferences
    @Published var activityHistory: [ActivityHistory] = []
    @Published var moodHistory: [MoodHistory] = []
    @Published var notificationHistory: [NotificationHistory] = []
    
    private let calendar = Calendar.current
    
    struct ActivityHistory: Identifiable, Codable {
        let id: UUID
        let activityName: String
        let timestamp: Date
        let duration: TimeInterval
        let engagementScore: Double
        let completionStatus: CompletionStatus
        
        enum CompletionStatus: String, Codable {
            case completed = "Completed"
            case skipped = "Skipped"
            case partiallyCompleted = "Partially Completed"
        }
    }
    
    struct MoodHistory: Identifiable, Codable {
        let id: UUID
        let mood: MoodTypes.Mood
        let timestamp: Date
        let activities: Set<MoodTypes.Activity>
        let notes: String
    }
    
    struct NotificationHistory: Identifiable, Codable {
        let id: UUID
        let type: UserPreferences.NotificationPreferences.NotificationType
        let timestamp: Date
        let wasOpened: Bool
        let responseTime: TimeInterval?
    }
    
    init() {
        // Load saved preferences or use defaults
        if let data = UserDefaults.standard.data(forKey: "userPreferences"),
           let decoded = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            preferences = decoded
        } else {
            preferences = UserPreferences.default
        }
    }
    
    // MARK: - Activity Personalization
    
    func updateActivityEngagement(_ activityName: String, engagement: Double) {
        preferences.activityEngagement[activityName] = engagement
        savePreferences()
    }
    
    func getOptimalTimeForActivity(_ activityName: String) -> Date? {
        // Find the most successful time for this activity
        let successfulAttempts = activityHistory.filter {
            $0.activityName == activityName && $0.engagementScore > 0.7
        }
        
        if let mostCommonHour = successfulAttempts
            .map({ calendar.component(.hour, from: $0.timestamp) })
            .mostCommonElement() {
            return calendar.date(bySettingHour: mostCommonHour, minute: 0, second: 0, of: Date())
        }
        
        return nil
    }
    
    // MARK: - Mood Analysis
    
    func updateMoodBaseline() {
        guard !moodHistory.isEmpty else { return }
        
        let recentMoods = moodHistory
            .filter { calendar.isDateInLastWeek($0.timestamp) }
            .map { Double($0.mood.numericValue) }
        
        preferences.moodBaseline = recentMoods.reduce(0.0, +) / Double(recentMoods.count)
        savePreferences()
    }
    
    func detectMoodChanges() -> [MoodChange] {
        var changes: [MoodChange] = []
        
        let recentMoods = moodHistory
            .filter { calendar.isDateInLastWeek($0.timestamp) }
            .sorted { $0.timestamp < $1.timestamp }
        
        for i in 1..<recentMoods.count {
            let previous = recentMoods[i-1]
            let current = recentMoods[i]
            
            let change = Double(current.mood.numericValue - previous.mood.numericValue)
            if abs(change) >= 2 {
                changes.append(MoodChange(
                    timestamp: current.timestamp,
                    magnitude: change,
                    previousMood: previous.mood,
                    currentMood: current.mood
                ))
            }
        }
        
        return changes
    }
    
    struct MoodChange {
        let timestamp: Date
        let magnitude: Double
        let previousMood: MoodTypes.Mood
        let currentMood: MoodTypes.Mood
    }
    
    // MARK: - Notification Optimization
    
    func getOptimalNotificationTime(for type: UserPreferences.NotificationPreferences.NotificationType) -> Date? {
        let relevantHistory = notificationHistory.filter { $0.type == type && $0.wasOpened }
        
        if let mostCommonHour = relevantHistory
            .map({ calendar.component(.hour, from: $0.timestamp) })
            .mostCommonElement() {
            return calendar.date(bySettingHour: mostCommonHour, minute: 0, second: 0, of: Date())
        }
        
        return nil
    }
    
    func shouldSendNotification(at time: Date) -> Bool {
        // Check if within quiet hours
        let hour = calendar.component(.hour, from: time)
        let quietStart = calendar.component(.hour, from: preferences.notificationPreferences.quietHours.start)
        let quietEnd = calendar.component(.hour, from: preferences.notificationPreferences.quietHours.end)
        
        if hour >= quietStart || hour < quietEnd {
            return false
        }
        
        // Check notification frequency
        let recentNotifications = notificationHistory.filter {
            calendar.isDate($0.timestamp, inSameDayAs: time)
        }
        
        return recentNotifications.count < 5 // Limit to 5 notifications per day
    }
    
    // MARK: - Content Adaptation
    
    func getAdaptedContent(for activity: String) -> UserPreferences.LearningPreferences.ContentType {
        let activityHistory = activityHistory.filter { $0.activityName == activity }
        
        // Get successful attempts
        let successfulAttempts = activityHistory.filter { $0.engagementScore > 0.7 }
        
        // Analyze content type preferences
        var contentScores: [UserPreferences.LearningPreferences.ContentType: Double] = [:]
        for type in UserPreferences.LearningPreferences.ContentType.allCases {
            let typeAttempts = successfulAttempts.filter { $0.completionStatus == .completed }
            let score = Double(typeAttempts.count) / Double(successfulAttempts.count)
            contentScores[type] = score
        }
        
        // Consider user preferences
        for type in preferences.learningPreferences.preferredContentTypes {
            contentScores[type] = (contentScores[type] ?? 0) + 0.2
        }
        
        // Return best scoring content type
        return contentScores.max(by: { $0.value < $1.value })?.key ?? .video
    }
    
    // MARK: - Data Persistence
    
    private func savePreferences() {
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: "userPreferences")
        }
    }
    
    // MARK: - Enhanced Recommendation Algorithms
    func getPersonalizedActivityRecommendations() -> [ActivityRecommendation] {
        var recommendations: [ActivityRecommendation] = []
        
        // Analyze mood patterns
        let recentMoods = moodHistory
            .filter { calendar.isDateInLastWeek($0.timestamp) }
            .sorted { $0.timestamp < $1.timestamp }
        
        // Get current mood
        let currentMood = recentMoods.last?.mood ?? .neutral
        
        // Get time of day
        let hour = calendar.component(.hour, from: Date())
        
        // Generate recommendations based on mood and time
        for activity in activityHistory.map({ $0.activityName }).uniqued() {
            let successRate = calculateActivitySuccessRate(activity)
            let optimalTime = getOptimalTimeForActivity(activity)
            let timeMatch = optimalTime.map { calendar.component(.hour, from: $0) == hour } ?? false
            
            // Calculate mood match score
            let moodMatchScore = calculateMoodMatchScore(activity, for: currentMood)
            
            // Calculate overall recommendation score
            let score = (successRate * 0.4) + (timeMatch ? 0.3 : 0.0) + (moodMatchScore * 0.3)
            
            if score > 0.5 {
                recommendations.append(ActivityRecommendation(
                    activity: activity,
                    score: score,
                    reason: generateRecommendationReason(
                        successRate: successRate,
                        timeMatch: timeMatch,
                        moodMatchScore: moodMatchScore
                    )
                ))
            }
        }
        
        return recommendations.sorted { $0.score > $1.score }
    }
    
    private func calculateActivitySuccessRate(_ activity: String) -> Double {
        let activityHistory = activityHistory.filter { $0.activityName == activity }
        guard !activityHistory.isEmpty else { return 0.0 }
        
        let successfulAttempts = activityHistory.filter { $0.engagementScore > 0.7 }
        return Double(successfulAttempts.count) / Double(activityHistory.count)
    }
    
    private func calculateMoodMatchScore(_ activity: String, for mood: MoodTypes.Mood) -> Double {
        let activityHistory = activityHistory.filter { $0.activityName == activity }
        guard !activityHistory.isEmpty else { return 0.0 }
        
        // Get mood entries that occurred after this activity
        let relevantMoodEntries = moodHistory.filter { entry in
            activityHistory.contains { activity in
                calendar.isDate(activity.timestamp, inSameDayAs: entry.timestamp) &&
                activity.timestamp < entry.timestamp
            }
        }
        
        // Calculate mood improvement score
        let moodImprovements = relevantMoodEntries.map { entry in
            Double(entry.mood.numericValue - mood.numericValue)
        }
        
        let averageImprovement = moodImprovements.reduce(0.0, +) / Double(moodImprovements.count)
        return (averageImprovement + 4) / 8 // Normalize to 0-1 range
    }
    
    private func generateRecommendationReason(successRate: Double, timeMatch: Bool, moodMatchScore: Double) -> String {
        var reasons: [String] = []
        
        if successRate > 0.7 {
            reasons.append("You've had great success with this activity")
        } else if successRate > 0.4 {
            reasons.append("You've had moderate success with this activity")
        }
        
        if timeMatch {
            reasons.append("This is your optimal time for this activity")
        }
        
        if moodMatchScore > 0.7 {
            reasons.append("This activity has improved your mood in the past")
        }
        
        return reasons.joined(separator: ", ")
    }
    
    struct ActivityRecommendation {
        let activity: String
        let score: Double
        let reason: String
    }
    
    // Smart Notification Scheduling
    func getOptimalNotificationSchedule() -> [ScheduledNotification] {
        var schedule: [ScheduledNotification] = []
        
        // Get activity recommendations
        let recommendations = getPersonalizedActivityRecommendations()
        
        for recommendation in recommendations {
            if let optimalTime = getOptimalTimeForActivity(recommendation.activity) {
                // Check if notification should be sent
                if shouldSendNotification(at: optimalTime) {
                    schedule.append(ScheduledNotification(
                        activity: recommendation.activity,
                        time: optimalTime,
                        type: .activityReminder,
                        priority: recommendation.score
                    ))
                }
            }
        }
        
        // Add mood check notifications
        let moodCheckTime = getOptimalNotificationTime(for: .moodCheck)
        if let time = moodCheckTime, shouldSendNotification(at: time) {
            schedule.append(ScheduledNotification(
                activity: "Mood Check",
                time: time,
                type: .moodCheck,
                priority: 0.8
            ))
        }
        
        return schedule.sorted { $0.priority > $1.priority }
    }
    
    struct ScheduledNotification {
        let activity: String
        let time: Date
        let type: UserPreferences.NotificationPreferences.NotificationType
        let priority: Double
    }
}

// MARK: - Helper Extensions

extension Array where Element: Hashable {
    func mostCommonElement() -> Element? {
        let counts = Dictionary(grouping: self, by: { $0 })
            .mapValues { $0.count }
        return counts.max(by: { $0.value < $1.value })?.key
    }
    
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

extension Calendar {
    func isDateInLastWeek(_ date: Date) -> Bool {
        let weekAgo = self.date(byAdding: .day, value: -7, to: Date())!
        return date >= weekAgo
    }
} 