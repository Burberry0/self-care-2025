import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var habitStore: HabitStore
    @EnvironmentObject var moodStore: MoodStore
    @State private var showingMoodSheet = false
    @State private var showingHabitsList = false
    @State private var showingHealthDetails = false
    @State private var showingMoodLog = false
    @State private var selectedMood: MoodTypes.Mood = .neutral
    @State private var selectedEnergy: MoodTypes.EnergyLevel = .medium
    @State private var selectedActivities: Set<MoodTypes.Activity> = []
    @State private var notes: String = ""
    @State private var showMoodSection = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick Mood Log
                    if showMoodSection {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How are you feeling?")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(MoodTypes.Mood.allCases, id: \.self) { mood in
                                        Button(action: {
                                            selectedMood = mood
                                            showingMoodLog = true
                                        }) {
                                            VStack {
                                                Text(mood.emoji)
                                                    .font(.system(size: 32))
                                                Text(mood.rawValue.capitalized)
                                                    .font(.caption)
                                            }
                                            .padding()
                                            .background(Color(.systemBackground))
                                            .cornerRadius(12)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    // Daily Overview Card
                    DailyOverviewCard()
                    
                    // Mood Summary                    
                    // Today's Habits
                    TodaysHabitsCard(showingHabitsList: $showingHabitsList)
                    
                    // Health Stats
                    HealthStatsCard(showingHealthDetails: $showingHealthDetails)
                    
                    // AI Insights
                    AIInsightsCard()
                }
                .padding()
            }
            .navigationTitle("Welcome, \(appState.currentUser?.name ?? "User")")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    LogMoodButton(showingMoodSheet: $showingMoodSheet)
                }
            }
            .sheet(isPresented: $showingMoodSheet) {
                MoodView()
            }
            .sheet(isPresented: $showingHabitsList) {
                HabitsView()
            }
            .sheet(isPresented: $showingHealthDetails) {
                HealthView()
            }
            .sheet(isPresented: $showingMoodLog) {
                NavigationView {
                    Form {
                        Section {
                            Picker("Mood", selection: $selectedMood) {
                                ForEach(MoodTypes.Mood.allCases, id: \.self) { mood in
                                    Text(mood.emoji)
                                        .tag(mood)
                                }
                            }
                            .pickerStyle(.segmented)
                            .font(.system(size: 24))
                        } header: {
                            Text("How are you feeling?")
                        }
                        
                        Section {
                            Picker("Energy", selection: $selectedEnergy) {
                                ForEach(MoodTypes.EnergyLevel.allCases, id: \.self) { level in
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
                        
                        Section {
                            ForEach(MoodTypes.Activity.allCases, id: \.self) { activity in
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
                        
                        Section {
                            TextEditor(text: $notes)
                                .frame(height: 100)
                        } header: {
                            Text("Notes")
                        }
                    }
                    .navigationTitle("Log Mood")
                    .navigationBarItems(
                        leading: Button("Cancel") { showingMoodLog = false },
                        trailing: Button("Save") {
                            saveMood()
                            showingMoodLog = false
                        }
                    )
                }
            }
        }
    }
    
    private func saveMood() {
        moodStore.addMoodEntry(
            selectedMood,
            energy: selectedEnergy,
            activities: selectedActivities,
            notes: notes
        )
        
        // Animate the mood section disappearing
        withAnimation(.easeOut(duration: 0.3)) {
            showMoodSection = false
        }
        
        // Reset form
        selectedMood = .neutral
        selectedEnergy = .medium
        selectedActivities = []
        notes = ""
    }
}

struct LogMoodButton: View {
    @Binding var showingMoodSheet: Bool
    
    var body: some View {
        Button(action: { showingMoodSheet = true }) {
            HStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 16, weight: .semibold))
                Text("Log Mood")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
            .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Supporting Views
struct DailyOverviewCard: View {
    @EnvironmentObject private var habitStore: HabitStore
    
    var completionText: String {
        let completed = habitStore.todaysHabits.filter { $0.isCompleted() }.count
        let total = habitStore.todaysHabits.count
        return "\(completed)/\(total)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Overview")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Today's Mood")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("😊")
                        .font(.system(size: 40))
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Habits Completed")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(completionText)
                        .font(.title2)
                        .bold()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct TodaysHabitsCard: View {
    @EnvironmentObject private var habitStore: HabitStore
    @Binding var showingHabitsList: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Habits")
                    .font(.headline)
                Spacer()
                Button(action: { showingHabitsList = true }) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                if habitStore.todaysHabits.isEmpty {
                    Text("No habits scheduled for today")
                        .foregroundColor(.secondary)
                        .padding(.vertical)
                } else {
                    VStack(spacing: 12) {
                        ForEach(habitStore.todaysHabits.prefix(3)) { habit in
                            HabitRow(
                                name: habit.name,
                                category: habit.category,
                                time: formatTime(from: habit.reminderTimes.first ?? Date()),
                                isCompleted: habit.isCompleted()
                            )
                            .onTapGesture {
                                habitStore.toggleHabit(habit)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func formatTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

struct HealthStatsCard: View {
    @Binding var showingHealthDetails: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Health Stats")
                    .font(.headline)
                Spacer()
                Button(action: { showingHealthDetails = true }) {
                    Text("Details")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    StatView(title: "Steps", value: "8,234", icon: "figure.walk")
                    StatView(title: "Heart Rate", value: "72", icon: "heart.fill")
                    StatView(title: "Sleep", value: "7h", icon: "bed.double.fill")
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct StatView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct AIInsightsCard: View {
    @State private var showingMeditation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Insights")
                .font(.headline)
            
            Text("Based on your recent patterns, you might want to try a 10-minute meditation session. Your stress levels have been slightly elevated this week.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: { showingMeditation = true }) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Start Meditation")
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .sheet(isPresented: $showingMeditation) {
            MeditationView(isPresented: $showingMeditation)
        }
    }
}

struct MeditationView: View {
    @Binding var isPresented: Bool
    @State private var timeRemaining = 600 // 10 minutes in seconds
    @State private var isActive = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("\(timeRemaining / 60):\(String(format: "%02d", timeRemaining % 60))")
                    .font(.system(size: 60, weight: .bold))
                
                Text(isActive ? "Meditating..." : "Ready to begin?")
                    .font(.title2)
                
                Button(action: {
                    isActive.toggle()
                    if !isActive {
                        timeRemaining = 600
                    }
                }) {
                    Text(isActive ? "Stop" : "Start")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 60)
                        .background(isActive ? Color.red : Color.blue)
                        .cornerRadius(30)
                }
            }
            .padding()
            .navigationTitle("Meditation")
            .navigationBarItems(trailing: Button("Close") { isPresented = false })
            .onReceive(timer) { _ in
                if isActive && timeRemaining > 0 {
                    timeRemaining -= 1
                } else if timeRemaining == 0 {
                    isActive = false
                }
            }
        }
    }
}

struct ActivityToggleRow: View {
    let activity: MoodTypes.Activity
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
