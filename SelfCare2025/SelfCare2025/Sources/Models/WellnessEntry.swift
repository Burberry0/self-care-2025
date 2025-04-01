import Foundation

struct WellnessEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    var mood: Int // 1-5 scale
    var activity: Int // minutes
    var sleep: Int // hours
    var notes: String?
    
    init(id: UUID = UUID(), date: Date = Date(), mood: Int, activity: Int, sleep: Int, notes: String? = nil) {
        self.id = id
        self.date = date
        self.mood = mood
        self.activity = activity
        self.sleep = sleep
        self.notes = notes
    }
} 