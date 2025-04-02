import SwiftUI

class HabitStore: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var todaysHabits: [Habit] = []
    
    private let habitsKey = "user_habits"
    
    init() {
        loadHabits()
    }
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        updateTodaysHabits()
        saveHabits()
    }
    
    func toggleHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            var updatedHabit = habits[index]
            updatedHabit.toggleCompletion()
            habits[index] = updatedHabit
            updateTodaysHabits()
            saveHabits()
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        updateTodaysHabits()
        saveHabits()
    }
    
    private func updateTodaysHabits() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        
        todaysHabits = habits.filter { habit in
            habit.taskDays.contains(weekday)
        }
    }
    
    private func saveHabits() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(habits)
            UserDefaults.standard.set(data, forKey: habitsKey)
        } catch {
            print("Error saving habits: \(error)")
        }
    }
    
    private func loadHabits() {
        guard let data = UserDefaults.standard.data(forKey: habitsKey) else {
            // No saved habits found, initialize with empty array
            habits = []
            updateTodaysHabits()
            return
        }
        
        do {
            let decoder = JSONDecoder()
            habits = try decoder.decode([Habit].self, from: data)
            updateTodaysHabits()
        } catch {
            print("Error loading habits: \(error)")
            habits = []
            updateTodaysHabits()
        }
    }
    
    // MARK: - Sample Data
    func addSampleHabits() {
        let sampleHabits: [Habit] = [
            Habit(
                name: "Morning Meditation",
                emoji: "🧘‍♂️",
                color: .blue,
                category: .mindfulness,
                type: .build,
                goalPeriod: "Daily",
                goalValue: 1,
                goalUnit: "session",
                taskDays: Set(1...7),
                timeRange: .morning,
                remindersEnabled: true,
                reminderTimes: [Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()]
            ),
            Habit(
                name: "Evening Walk",
                emoji: "🚶‍♂️",
                color: .green,
                category: .fitness,
                type: .build,
                goalPeriod: "Daily",
                goalValue: 30,
                goalUnit: "minutes",
                taskDays: Set(1...7),
                timeRange: .evening,
                remindersEnabled: true,
                reminderTimes: [Calendar.current.date(from: DateComponents(hour: 18, minute: 0)) ?? Date()]
            ),
            Habit(
                name: "Read a Book",
                emoji: "📚",
                color: .orange,
                category: .learning,
                type: .build,
                goalPeriod: "Daily",
                goalValue: 20,
                goalUnit: "pages",
                taskDays: Set(1...7),
                timeRange: .evening,
                remindersEnabled: true,
                reminderTimes: [Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date()]
            )
        ]
        
        for habit in sampleHabits {
            addHabit(habit)
        }
    }
} 