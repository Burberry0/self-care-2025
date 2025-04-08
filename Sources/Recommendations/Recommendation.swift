import Foundation
import SwiftUI

struct Recommendation: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var type: RecommendationType
    var category: Category
    var timeRange: TimeRange
    var duration: Int // in minutes
    var priority: Priority
    var feedback: Feedback?
    var lastSuggested: Date
    var engagementScore: Double // 0.0 to 1.0
    
    enum RecommendationType: String, Codable, CaseIterable {
        case activity = "Activity"
        case challenge = "Challenge"
        case article = "Article"
        case meditation = "Meditation"
        case exercise = "Exercise"
        case journaling = "Journaling"
        
        var icon: String {
            switch self {
            case .activity: return "sparkles"
            case .challenge: return "trophy.fill"
            case .article: return "doc.text.fill"
            case .meditation: return "brain.head.profile"
            case .exercise: return "figure.run"
            case .journaling: return "pencil.line"
            }
        }
    }
    
    enum Priority: Int, Codable, Comparable {
        case low = 1
        case medium = 2
        case high = 3
        
        static func < (lhs: Priority, rhs: Priority) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
    
    struct Feedback: Codable {
        var isHelpful: Bool
        var comment: String?
        var timestamp: Date
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        type: RecommendationType,
        category: Category,
        timeRange: TimeRange,
        duration: Int,
        priority: Priority = .medium,
        feedback: Feedback? = nil,
        lastSuggested: Date = Date(),
        engagementScore: Double = 0.5
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.category = category
        self.timeRange = timeRange
        self.duration = duration
        self.priority = priority
        self.feedback = feedback
        self.lastSuggested = lastSuggested
        self.engagementScore = engagementScore
    }
}

class RecommendationStore: ObservableObject {
    @Published var recommendations: [Recommendation] = []
    @Published var userPreferences: [Category: Double] = [:]
    @Published var engagementHistory: [UUID: [Date]] = [:]
    
    private let calendar = Calendar.current
    
    func addRecommendation(_ recommendation: Recommendation) {
        recommendations.append(recommendation)
        saveRecommendations()
    }
    
    func updateFeedback(for recommendation: Recommendation, isHelpful: Bool, comment: String? = nil) {
        if let index = recommendations.firstIndex(where: { $0.id == recommendation.id }) {
            recommendations[index].feedback = Recommendation.Feedback(
                isHelpful: isHelpful,
                comment: comment,
                timestamp: Date()
            )
            updateEngagementScore(for: recommendation.id, isEngaged: isHelpful)
            saveRecommendations()
        }
    }
    
    func getPersonalizedRecommendations(
        for timeRange: TimeRange,
        limit: Int = 3
    ) -> [Recommendation] {
        // Filter by time range and sort by priority and engagement score
        return recommendations
            .filter { $0.timeRange == timeRange }
            .sorted { lhs, rhs in
                if lhs.priority == rhs.priority {
                    return lhs.engagementScore > rhs.engagementScore
                }
                return lhs.priority > rhs.priority
            }
            .prefix(limit)
            .map { $0 }
    }
    
    func updateEngagementScore(for recommendationId: UUID, isEngaged: Bool) {
        if var history = engagementHistory[recommendationId] {
            history.append(Date())
            engagementHistory[recommendationId] = history
        } else {
            engagementHistory[recommendationId] = [Date()]
        }
        
        // Calculate new engagement score based on history
        if let index = recommendations.firstIndex(where: { $0.id == recommendationId }) {
            let history = engagementHistory[recommendationId] ?? []
            let recentEngagement = history.filter { calendar.isDateInToday($0) }
            let score = Double(recentEngagement.count) / 5.0 // Normalize to 0-1
            recommendations[index].engagementScore = min(max(score, 0.0), 1.0)
        }
    }
    
    func createAdaptiveChallenge(
        basedOn mood: MoodTypes.Mood,
        activities: Set<MoodTypes.Activity>
    ) -> Recommendation {
        // Analyze mood and activities to create a personalized challenge
        let challengeType: Recommendation.RecommendationType
        let duration: Int
        
        if activities.contains(.meditation) {
            challengeType = .meditation
            duration = 10
        } else if activities.contains(.reading) {
            challengeType = .article
            duration = 15
        } else {
            challengeType = .activity
            duration = 20
        }
        
        return Recommendation(
            title: "7-Day \(mood.rawValue.capitalized) Relief Program",
            description: "A personalized program to help manage your current mood state",
            type: challengeType,
            category: .mindfulness,
            timeRange: .anytime,
            duration: duration,
            priority: .high
        )
    }
    
    private func saveRecommendations() {
        if let encoded = try? JSONEncoder().encode(recommendations) {
            UserDefaults.standard.set(encoded, forKey: "recommendations")
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "recommendations"),
           let decoded = try? JSONDecoder().decode([Recommendation].self, from: data) {
            recommendations = decoded
        }
    }
} 