import Foundation
import SwiftUI

class MoodStore: ObservableObject {
    @Published var moodEntries: [MoodEntry] = []
    @Published var moodInsights: [MoodInsight] = []
    @Published var moodPatterns: [String: Any] = [:]
    
    var averageMood: Double {
        guard !moodEntries.isEmpty else { return 0 }
        let sum = moodEntries.reduce(0) { $0 + $1.mood.numericValue }
        return Double(sum) / Double(moodEntries.count)
    }
    
    var bestMoodDay: Date? {
        moodEntries.max(by: { $0.mood.rawValue < $1.mood.rawValue })?.timestamp
    }
    
    var mostCommonMood: MoodTypes.Mood {
        var moodCounts: [MoodTypes.Mood: Int] = [:]
        
        for entry in moodEntries {
            moodCounts[entry.mood, default: 0] += 1
        }
        
        return moodCounts.max(by: { $0.value < $1.value })?.key ?? .neutral
    }
    
    var moodTrackingConsistency: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!
        
        let entriesThisWeek = moodEntries.filter { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: weekAgo) || entry.timestamp > weekAgo
        }
        
        let uniqueDays = Set(entriesThisWeek.map { entry in
            calendar.startOfDay(for: entry.timestamp)
        })
        
        let consistency = (Double(uniqueDays.count) / 7.0) * 100
        return Int(consistency)
    }
    
    func addMoodEntry(_ mood: MoodTypes.Mood, 
                     energy: MoodTypes.EnergyLevel = .medium,
                     activities: Set<MoodTypes.Activity> = [],
                     notes: String = "") {
        let entry = MoodEntry(mood: mood, 
                            energy: energy,
                            activities: activities,
                            notes: notes)
        moodEntries.append(entry)
        saveMoodEntries()
        moodPatterns = analyzeMoodPatterns()
    }
    
    func getMoodEntries(for timeRange: ReportsView.TimeRange) -> [MoodEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        switch timeRange {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!
            return moodEntries.filter { $0.timestamp >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: today)!
            return moodEntries.filter { $0.timestamp >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: today)!
            return moodEntries.filter { $0.timestamp >= yearAgo }
        }
    }
    
    func analyzeMoodPatterns() -> [String: Any] {
        var patterns: [String: Any] = [:]
        
        // Calculate daily averages
        var dailyAverages: [Int: Double] = [:]
        let calendar = Calendar.current
        
        for day in 1...7 {
            let entries = moodEntries.filter { entry in
                calendar.component(.weekday, from: entry.timestamp) == day
            }
            
            if !entries.isEmpty {
                let sum = entries.reduce(0) { $0 + $1.mood.numericValue }
                dailyAverages[day] = Double(sum) / Double(entries.count)
            }
        }
        
        patterns["dailyAverages"] = dailyAverages
        
        // Find common activities
        let activityCounts = moodEntries
            .flatMap { $0.activities }
            .reduce(into: [MoodTypes.Activity: Int]()) { counts, activity in
                counts[activity, default: 0] += 1
            }
        
        patterns["commonActivities"] = activityCounts
        
        return patterns
    }
    
    private func saveMoodEntries() {
        // Save mood entries to UserDefaults
        if let encoded = try? JSONEncoder().encode(moodEntries) {
            UserDefaults.standard.set(encoded, forKey: "moodEntries")
        }
    }
    
    init() {
        // Load saved mood entries
        if let data = UserDefaults.standard.data(forKey: "moodEntries"),
           let decoded = try? JSONDecoder().decode([MoodEntry].self, from: data) {
            moodEntries = decoded
        }
        moodPatterns = analyzeMoodPatterns()
    }
}

struct MoodEntry: Identifiable, Codable {
    let id: UUID
    let mood: MoodTypes.Mood
    let energy: MoodTypes.EnergyLevel
    let activities: Set<MoodTypes.Activity>
    let notes: String
    let timestamp: Date
    
    init(id: UUID = UUID(), 
         mood: MoodTypes.Mood, 
         energy: MoodTypes.EnergyLevel = .medium,
         activities: Set<MoodTypes.Activity> = [],
         notes: String = "",
         timestamp: Date = Date()) {
        self.id = id
        self.mood = mood
        self.energy = energy
        self.activities = activities
        self.notes = notes
        self.timestamp = timestamp
    }
}

struct MoodInsight: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let type: InsightType
    
    init(id: UUID = UUID(), title: String, description: String, type: InsightType) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
    }
}

enum InsightType {
    case positive
    case neutral
    case negative
} 
