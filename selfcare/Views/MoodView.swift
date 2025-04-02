import SwiftUI

struct MoodView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMood: Mood = .neutral
    @State private var selectedEnergy: EnergyLevel = .medium
    @State private var selectedActivities: Set<Activity> = []
    @State private var notes: String = ""
    @State private var showingHistory = false
    
    var body: some View {
        NavigationView {
            Form {
                moodSection
                energySection
                activitiesSection
                notesSection
                historySection
            }
            .navigationTitle("Log Mood")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { dismiss() }
            )
            .sheet(isPresented: $showingHistory) {
                MoodHistoryView()
            }
        }
    }
    
    private var moodSection: some View {
        Section {
            Picker("Mood", selection: $selectedMood) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    Text(mood.emoji)
                        .tag(mood)
                }
            }
            .pickerStyle(.segmented)
            .font(.system(size: 24))
        } header: {
            Text("How are you feeling?")
        }
    }
    
    private var energySection: some View {
        Section {
            Picker("Energy", selection: $selectedEnergy) {
                ForEach(EnergyLevel.allCases, id: \.self) { level in
                    HStack {
                        Image(systemName: level.icon)
                        Text(level.rawValue.capitalized)
                    }
                    .tag(level)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            Text("Energy Level")
        }
    }
    
    private var activitiesSection: some View {
        Section {
            ForEach(Activity.allCases, id: \.self) { activity in
                ActivityToggleRow(
                    activity: activity,
                    isSelected: selectedActivities.contains(activity),
                    onToggle: { isSelected in
                        if isSelected {
                            selectedActivities.insert(activity)
                        } else {
                            selectedActivities.remove(activity)
                        }
                    }
                )
            }
        } header: {
            Text("Activities")
        }
    }
    
    private var notesSection: some View {
        Section {
            TextEditor(text: $notes)
                .frame(height: 100)
        } header: {
            Text("Notes")
        }
    }
    
    private var historySection: some View {
        Section {
            Button(action: { showingHistory = true }) {
                Label("View Mood History", systemImage: "clock")
            }
        }
    }
}

struct ActivityToggleRow: View {
    let activity: Activity
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        Toggle(isOn: Binding(
            get: { isSelected },
            set: { onToggle($0) }
        )) {
            HStack {
                Image(systemName: activity.systemImage)
                Text(activity.rawValue.capitalized)
            }
        }
    }
}

// MARK: - Mood History View
struct MoodHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<7) { _ in
                    HStack {
                        Text("😊")
                            .font(.title)
                        VStack(alignment: .leading) {
                            Text("Happy")
                                .font(.headline)
                            Text("2 hours ago")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Mood History")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

// MARK: - Mood Analysis View
struct MoodAnalysisView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood Analysis")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 15) {
                AnalysisRow(title: "Most Common Mood", value: "Happy", icon: "😊")
                AnalysisRow(title: "Best Time of Day", value: "Morning", icon: "sunrise.fill")
                AnalysisRow(title: "Mood Triggers", value: "Exercise, Social", icon: "bolt.fill")
                AnalysisRow(title: "Weekly Trend", value: "Improving", icon: "chart.line.uptrend.xyaxis")
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            .padding(.horizontal)
        }
    }
}

struct AnalysisRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.title2)
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
} 