import Foundation

struct HealthData: Codable {
    var steps: Int
    var sleepHours: Double
    var waterIntake: Double
    var heartRate: Int?
    var weight: Double?
    
    init(steps: Int = 0, sleepHours: Double = 0, waterIntake: Double = 0, heartRate: Int? = nil, weight: Double? = nil) {
        self.steps = steps
        self.sleepHours = sleepHours
        self.waterIntake = waterIntake
        self.heartRate = heartRate
        self.weight = weight
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