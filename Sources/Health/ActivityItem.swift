import Foundation

struct ActivityItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let subtitle: String
    let date: Date
    let icon: String
    
    init(title: String, subtitle: String, date: Date = Date(), icon: String) {
        self.id = UUID()
        self.title = title
        self.subtitle = subtitle
        self.date = date
        self.icon = icon
    }
} 