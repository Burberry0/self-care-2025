import Foundation

struct HealthData: Codable {
    var steps: Int
    var heartRate: Int?
    var sleepHours: Double?
    var stressLevel: StressLevel
    var lastSync: Date
    
    init() {
        self.steps = 0
        self.heartRate = nil
        self.sleepHours = nil
        self.stressLevel = .unknown
        self.lastSync = Date()
    }
}

enum StressLevel: String, Codable {
    case low
    case medium
    case high
    case unknown
}

struct BiometricData: Codable {
    let timestamp: Date
    let type: BiometricType
    let value: Double
    
    enum BiometricType: String, Codable {
        case heartRate
        case steps
        case sleep
        case stress
    }
} 