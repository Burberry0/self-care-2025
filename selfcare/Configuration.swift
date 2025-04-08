import Foundation

enum Configuration {
    enum Permission: String {
        case location = "We use your location to track your activity patterns and provide personalized recommendations."
        case motion = "We use motion and fitness tracking to monitor your physical activity and provide better health insights."
        case notifications = "We'll send you helpful reminders and insights about your activities."
        
        static var requiredPermissions: [Permission] {
            return [.location, .motion, .notifications]
        }
    }
    
    static let backgroundModes = ["location", "processing"]
    
    static func requestPermissions() {
        // Permissions will be requested when needed by respective managers
    }
} 