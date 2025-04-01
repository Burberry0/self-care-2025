import Foundation

class WellnessService: ObservableObject {
    @Published private(set) var entries: [WellnessEntry] = []
    
    func addEntry(_ entry: WellnessEntry) {
        entries.append(entry)
        // TODO: Implement persistence
    }
    
    func getEntry(for date: Date) -> WellnessEntry? {
        return entries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func updateEntry(_ entry: WellnessEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            // TODO: Implement persistence
        }
    }
    
    func deleteEntry(_ entry: WellnessEntry) {
        entries.removeAll { $0.id == entry.id }
        // TODO: Implement persistence
    }
} 