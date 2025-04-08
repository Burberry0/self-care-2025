import SwiftUI
import Charts

struct MoodView: View {
    @EnvironmentObject var moodStore: MoodStore
    @State private var selectedTimeRange: TimeRange = .week
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Range Selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(TimeRange.allCases, id: \.self) { range in
                                Button(action: { selectedTimeRange = range }) {
                                    Text(range.rawValue)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedTimeRange == range ? Color.blue : Color(.systemGray6))
                                        .foregroundColor(selectedTimeRange == range ? .white : .primary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Mood Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mood Trends")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        Chart {
                            ForEach(moodStore.moodEntries) { entry in
                                LineMark(
                                    x: .value("Date", entry.timestamp),
                                    y: .value("Mood", entry.mood.rawValue)
                                )
                                .foregroundStyle(Color.blue)
                                
                                PointMark(
                                    x: .value("Date", entry.timestamp),
                                    y: .value("Mood", entry.mood.rawValue)
                                )
                                .foregroundStyle(Color.blue)
                            }
                        }
                        .frame(height: 200)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Mood Insights
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Insights")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 15) {
                            InsightRow(
                                title: "Most Common Mood",
                                value: mostCommonMood,
                                icon: "chart.bar.fill",
                                color: .blue
                            )
                            
                            InsightRow(
                                title: "Energy Level",
                                value: averageEnergyLevel,
                                icon: "bolt.fill",
                                color: .orange
                            )
                            
                            InsightRow(
                                title: "Best Time of Day",
                                value: bestTimeOfDay,
                                icon: "clock.fill",
                                color: .purple
                            )
                            
                            InsightRow(
                                title: "Common Activities",
                                value: commonActivities,
                                icon: "figure.walk",
                                color: .green
                            )
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Recent Mood History
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Moods")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ForEach(moodStore.moodEntries.prefix(5)) { entry in
                                HStack {
                                    Text(entry.mood.emoji)
                                        .font(.title)
                                    VStack(alignment: .leading) {
                                        Text(entry.mood.rawValue.capitalized)
                                            .font(.headline)
                                        Text(entry.timestamp, style: .relative)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if !entry.activities.isEmpty {
                                        HStack(spacing: 4) {
                                            ForEach(Array(entry.activities.prefix(3)), id: \.self) { activity in
                                                Image(systemName: activity.systemImage)
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Mood")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private var mostCommonMood: String {
        let moodCounts = Dictionary(grouping: moodStore.moodEntries, by: { $0.mood })
            .mapValues { $0.count }
        return moodCounts.max(by: { $0.value < $1.value })?.key.rawValue.capitalized ?? "N/A"
    }
    
    private var averageEnergyLevel: String {
        let energyValues = moodStore.moodEntries.map { entry in
            switch entry.energy {
            case .low: return 1
            case .medium: return 2
            case .high: return 3
            }
        }
        let total = energyValues.reduce(0, +)
        let average = Double(total) / Double(moodStore.moodEntries.count)
        return String(format: "%.1f", average)
    }
    
    private var bestTimeOfDay: String {
        let hourCounts = Dictionary(grouping: moodStore.moodEntries) { entry in
            Calendar.current.component(.hour, from: entry.timestamp)
        }
        .mapValues { $0.count }
        
        if let bestHour = hourCounts.max(by: { $0.value < $1.value })?.key {
            let formatter = DateFormatter()
            formatter.dateFormat = "h a"
            let date = Calendar.current.date(bySettingHour: bestHour, minute: 0, second: 0, of: Date())!
            return formatter.string(from: date)
        }
        return "N/A"
    }
    
    private var commonActivities: String {
        let activityCounts = moodStore.moodEntries.flatMap { $0.activities }
            .reduce(into: [MoodTypes.Activity: Int]()) { counts, activity in
                counts[activity, default: 0] += 1
            }
        
        return activityCounts.max(by: { $0.value < $1.value })?.key.rawValue.capitalized ?? "N/A"
    }
} 