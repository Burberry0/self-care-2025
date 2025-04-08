import SwiftUI

struct HealthView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var healthStore = HealthStore()
    @State private var selectedTimeRange: HealthTimeRange = .week
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Range Selector
                    TimeRangeSelector(selectedRange: $selectedTimeRange)
                    
                    // Health Stats Overview
                    HealthStatsOverview()
                    
                    // Activity Trends
                    ActivityTrendsView()
                    
                    // Sleep Analysis
                    SleepAnalysisView()
                    
                    // Stress Levels
                    StressLevelsView()
                    
                    // Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(
                            title: "Steps Today",
                            value: "\(Int(healthStore.stepsToday))",
                            icon: "figure.walk",
                            color: .blue,
                            alignment: .leading
                        )
                        
                        StatCard(
                            title: "Active Minutes",
                            value: "\(Int(healthStore.activeMinutesToday))",
                            icon: "flame.fill",
                            color: .orange,
                            alignment: .leading
                        )
                        
                        StatCard(
                            title: "Distance",
                            value: String(format: "%.1f km", healthStore.distanceToday),
                            icon: "figure.walk.motion",
                            color: .green,
                            alignment: .leading
                        )
                        
                        StatCard(
                            title: "Calories",
                            value: "\(Int(healthStore.activeCaloriesToday))",
                            icon: "bolt.heart.fill",
                            color: .red,
                            alignment: .leading
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Health")
            .onAppear {
                healthStore.refreshData()
            }
        }
    }
}

enum HealthTimeRange: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

struct TimeRangeSelector: View {
    @Binding var selectedRange: HealthTimeRange
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(HealthTimeRange.allCases, id: \.self) { range in
                    Button(action: { selectedRange = range }) {
                        Text(range.rawValue)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedRange == range ? Color.blue : Color(.systemGray6))
                            .foregroundColor(selectedRange == range ? .white : .primary)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct HealthStatsOverview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 15) {
                StatCard(
                    title: "Steps",
                    value: "8,234",
                    icon: "figure.walk",
                    color: .blue,
                    alignment: .center
                )
                
                StatCard(
                    title: "Heart Rate",
                    value: "72",
                    icon: "heart.fill",
                    color: .red,
                    alignment: .center
                )
                
                StatCard(
                    title: "Sleep",
                    value: "7h",
                    icon: "bed.double.fill",
                    color: .purple,
                    alignment: .center
                )
            }
            .padding(.horizontal)
        }
    }
}

struct ActivityTrendsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity Trends")
                .font(.headline)
                .padding(.horizontal)
            
            // Placeholder for activity chart
            Rectangle()
                .fill(Color(.systemGray6))
                .frame(height: 200)
                .overlay(
                    Text("Activity Chart")
                        .foregroundColor(.secondary)
                )
                .cornerRadius(12)
                .padding(.horizontal)
        }
    }
}

struct SleepAnalysisView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sleep Analysis")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 15) {
                SleepStatRow(title: "Average Sleep", value: "7h 30m", icon: "bed.double.fill")
                SleepStatRow(title: "Sleep Quality", value: "85%", icon: "star.fill")
                SleepStatRow(title: "Deep Sleep", value: "2h 15m", icon: "moon.fill")
                SleepStatRow(title: "REM Sleep", value: "1h 45m", icon: "brain.head.profile")
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            .padding(.horizontal)
        }
    }
}

struct SleepStatRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.purple)
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
}

struct StressLevelsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stress Levels")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 15) {
                StressLevelRow(level: "Low", percentage: 60, color: .green)
                StressLevelRow(level: "Medium", percentage: 30, color: .yellow)
                StressLevelRow(level: "High", percentage: 10, color: .red)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            .padding(.horizontal)
        }
    }
}

struct StressLevelRow: View {
    let level: String
    let percentage: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(level)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(percentage)%")
                    .bold()
            }
            
            GeometryReader { geometry in
                Rectangle()
                    .fill(color)
                    .frame(width: geometry.size.width * CGFloat(percentage) / 100)
            }
            .frame(height: 8)
            .background(Color(.systemGray6))
            .cornerRadius(4)
        }
    }
} 