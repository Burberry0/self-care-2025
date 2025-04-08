import Foundation
import SwiftUI

// MARK: - Mood Types
enum MoodTypes {
    struct MoodEntry: Codable, Identifiable {
        var id: UUID
        let mood: Mood
        let energy: EnergyLevel
        let activities: Set<Activity>
        let notes: String
        let timestamp: Date
        
        init(mood: Mood, energy: EnergyLevel, activities: Set<Activity>, notes: String) {
            self.id = UUID()
            self.mood = mood
            self.energy = energy
            self.activities = activities
            self.notes = notes
            self.timestamp = Date()
        }
    }
    
    enum Mood: String, CaseIterable, Codable {
        case happy = "happy"
        case neutral = "neutral"
        case sad = "sad"
        case anxious = "anxious"
        case angry = "angry"
        
        var emoji: String {
            switch self {
            case .happy: return "😊"
            case .neutral: return "😐"
            case .sad: return "😢"
            case .anxious: return "😰"
            case .angry: return "😠"
            }
        }
        
        var numericValue: Int {
            switch self {
            case .happy: return 5
            case .neutral: return 3
            case .sad: return 1
            case .anxious: return 2
            case .angry: return 1
            }
        }
    }
    
    enum EnergyLevel: String, CaseIterable, Codable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        
        var icon: String {
            switch self {
            case .low: return "battery.25"
            case .medium: return "battery.50"
            case .high: return "battery.100"
            }
        }
    }
    
    enum Activity: String, CaseIterable, Codable {
        case exercise = "exercise"
        case meditation = "meditation"
        case social = "social"
        case work = "work"
        case sleep = "sleep"
        case reading = "reading"
        case creative = "creative"
        
        var systemImage: String {
            switch self {
            case .exercise: return "figure.run"
            case .meditation: return "brain.head.profile"
            case .social: return "person.2"
            case .work: return "briefcase"
            case .sleep: return "bed.double"
            case .reading: return "book"
            case .creative: return "paintbrush"
            }
        }
    }
} 