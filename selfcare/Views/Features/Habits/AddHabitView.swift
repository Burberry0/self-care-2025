import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var habitStore: HabitStore
    @Binding var isPresented: Bool
    
    @State private var name = ""
    @State private var description = ""
    @State private var category: Category = .health
    @State private var frequency: Frequency = .daily
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    @State private var selectedDays: Set<Int> = Set(1...7) // Default to every day
    @State private var selectedType: HabitType = .build
    @State private var selectedTimeRange: TimeRange = .anytime
    @State private var goalValue: Int = 1
    @State private var goalUnit: String = "times"
    
    private let frequencies = Frequency.allCases
    private let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private let goalUnits = ["times", "minutes", "pages", "glasses", "steps"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Info")) {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                    
                    Picker("Category", selection: $category) {
                        ForEach(Category.allCases, id: \.self) { category in
                            Text(category.rawValue)
                                .tag(category)
                        }
                    }
                    
                    Picker("Type", selection: $selectedType) {
                        ForEach(HabitType.allCases, id: \.self) { type in
                            Text(type.rawValue)
                                .tag(type)
                        }
                    }
                }
                
                Section(header: Text("Goal")) {
                    Stepper("Goal Value: \(goalValue)", value: $goalValue, in: 1...100)
                    
                    Picker("Unit", selection: $goalUnit) {
                        ForEach(goalUnits, id: \.self) { unit in
                            Text(unit)
                                .tag(unit)
                        }
                    }
                }
                
                Section(header: Text("Schedule")) {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(frequencies, id: \.self) { frequency in
                            Text(frequency.rawValue)
                                .tag(frequency)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    ForEach(weekDays.indices, id: \.self) { index in
                        Toggle(weekDays[index], isOn: Binding(
                            get: { selectedDays.contains(index + 1) },
                            set: { isSelected in
                                if isSelected {
                                    selectedDays.insert(index + 1)
                                } else {
                                    selectedDays.remove(index + 1)
                                }
                            }
                        ))
                    }
                    
                    Picker("Time of Day", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { timeRange in
                            Text(timeRange.rawValue)
                                .tag(timeRange)
                        }
                    }
                }
                
                Section(header: Text("Reminder")) {
                    DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                }
            }
            .navigationTitle("New Habit")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                    isPresented = false
                },
                trailing: Button("Save") {
                    saveHabit()
                    dismiss()
                    isPresented = false
                }
                .disabled(name.isEmpty || selectedDays.isEmpty)
            )
        }
    }
    
    private func saveHabit() {
        let habit = Habit(
            name: name,
            emoji: "📝", // TODO: Allow emoji selection
            color: .blue, // TODO: Allow color selection
            category: category,
            type: selectedType,
            goalPeriod: frequency.rawValue,
            goalValue: goalValue,
            goalUnit: goalUnit,
            taskDays: selectedDays,
            timeRange: selectedTimeRange,
            remindersEnabled: true,
            reminderTimes: [reminderTime]
        )
        
        habitStore.addHabit(habit)
    }
}

#Preview {
    AddHabitView(isPresented: .constant(true))
        .environmentObject(HabitStore())
} 