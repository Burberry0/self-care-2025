import Foundation

struct UserPreferences: Codable {
    var preferredActivityTimes: [TimeRange: [Date]]
    var activityEngagement: [String: Double] // activity name -> engagement score
    var moodBaseline: Double
    var notificationPreferences: NotificationPreferences
    var learningPreferences: LearningPreferences
    
    struct NotificationPreferences: Codable {
        var enabled: Bool
        var quietHours: QuietHours
        var preferredNotificationTypes: Set<NotificationType>
        
        struct QuietHours: Codable {
            var start: Date
            var end: Date
        }
        
        enum NotificationType: String, Codable, CaseIterable {
            case activityReminder = "Activity Reminder"
            case moodCheck = "Mood Check"
            case progressUpdate = "Progress Update"
            case challengeReminder = "Challenge Reminder"
        }
    }
    
    struct LearningPreferences: Codable {
        var preferredContentTypes: Set<ContentType>
        var difficultyLevel: DifficultyLevel
        var learningStyle: LearningStyle
        
        enum ContentType: String, Codable {
            case video = "Video"
            case audio = "Audio"
            case text = "Text"
            case interactive = "Interactive"
            
            static var allCases: [ContentType] {
                [.video, .audio, .text, .interactive]
            }
        }
        
        enum DifficultyLevel: Int, Codable {
            case beginner = 1
            case intermediate = 2
            case advanced = 3
        }
        
        enum LearningStyle: String, Codable {
            case visual = "Visual"
            case auditory = "Auditory"
            case kinesthetic = "Kinesthetic"
            case reading = "Reading"
        }
    }
    
    static var `default`: UserPreferences {
        let calendar = Calendar.current
        return UserPreferences(
            preferredActivityTimes: [:],
            activityEngagement: [:],
            moodBaseline: 0.0,
            notificationPreferences: NotificationPreferences(
                enabled: true,
                quietHours: NotificationPreferences.QuietHours(
                    start: calendar.date(from: DateComponents(hour: 22)) ?? Date(),
                    end: calendar.date(from: DateComponents(hour: 7)) ?? Date()
                ),
                preferredNotificationTypes: [.activityReminder, .moodCheck]
            ),
            learningPreferences: LearningPreferences(
                preferredContentTypes: [.video, .interactive],
                difficultyLevel: .beginner,
                learningStyle: .visual
            )
        )
    }
} 