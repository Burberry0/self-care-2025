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
    
    private let frequencies = [Frequency.daily, .weekly, .monthly]
    private let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Habit Details")) {
                    TextField("Habit Name", text: $name)
                        .textContentType(.none)
                        .disableAutocorrection(true)
                    TextField("Description", text: $description)
                        .textContentType(.none)
                }
                
                Section(header: Text("Category")) {
                    Picker("Category", selection: $category) {
                        ForEach(Category.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.navigationLink)
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
            group: nil,
            type: .build,
            goalPeriod: frequency.rawValue,
            goalValue: 1,
            goalUnit: "",
            taskDays: selectedDays,
            timeRange: .anytime,
            remindersEnabled: true,
            reminderTimes: [reminderTime],
            ringtone: "Default",
            reminderMessage: description.isEmpty ? nil : description,
            showMemoAfterCompletion: false,
            habitBarGesture: "Mark as done",
            chartType: .bar,
            startDate: Date()
        )
        
        habitStore.addHabit(habit)
    }
}

#Preview {
    AddHabitView(isPresented: .constant(true))
        .environmentObject(HabitStore())
} 