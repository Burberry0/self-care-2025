import SwiftUI
import Charts

// Core
import Core.AppState

// Stores
import Habits.HabitStore
import User.PersonalizationStore

struct HabitsView: View {
    @EnvironmentObject private var habitStore: HabitStore
    @State private var selectedCategory: Category?
    @State private var showingAddHabit = false
    
    var filteredHabits: [Habit] {
        if let category = selectedCategory {
            return habitStore.habits.filter { $0.category == category }
        }
        return habitStore.habits
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: -19) {
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 1) {
                        // All category button
                        CategoryButton(
                            title: "All",
                            systemImage: "list.bullet",
                            isSelected: selectedCategory == nil,
                            action: {
                                print("Selected: All")
                                selectedCategory = nil
                            }
                        )
                        
                        // Category buttons
                        ForEach(Category.allCases, id: \.self) { category in
                            CategoryButton(
                                title: category.rawValue,
                                systemImage: category.icon,
                                isSelected: selectedCategory == category,
                                action: {
                                    print("Selected category: \(category.rawValue)")
                                    selectedCategory = category
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))
                
                // Main list
                List {
                    TodaysHabitsSection(habits: filteredHabits)
                    AllHabitsSection(habits: filteredHabits)
                }
                .listStyle(.plain)
                .listRowSpacing(5)
                .padding(.top, -1)
            }
            .navigationTitle("Habits")
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddHabit = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView(isPresented: $showingAddHabit)
            }
        }
    }
    
    private func formatTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

struct TodaysHabitsSection: View {
    @EnvironmentObject private var habitStore: HabitStore
    let habits: [Habit]
    
    var body: some View {
        Section {
            if habitStore.todaysHabits.isEmpty {
                Text("No habits scheduled for today")
                    .foregroundColor(.secondary)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(habitStore.todaysHabits) { habit in
                    HabitRow(
                        name: habit.name,
                        category: habit.category,
                        time: formatTime(from: habit.reminderTimes.first ?? Date()),
                        isCompleted: habit.isCompleted()
                    )
                    .onTapGesture {
                        habitStore.toggleHabit(habit)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            habitStore.deleteHabit(habit)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                    .listRowBackground(Color.clear)
                }
            }
        } header: {
            Text("Today's Habits")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .textCase(nil)
        }
    }
    
    private func formatTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

struct AllHabitsSection: View {
    @EnvironmentObject private var habitStore: HabitStore
    let habits: [Habit]
    
    var body: some View {
        Section {
            if habits.isEmpty {
                Text("No habits found")
                    .foregroundColor(.secondary)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(habits) { habit in
                    HabitRow(
                        name: habit.name,
                        category: habit.category,
                        time: formatTime(from: habit.reminderTimes.first ?? Date()),
                        isCompleted: habit.isCompleted()
                    )
                    .onTapGesture {
                        habitStore.toggleHabit(habit)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            habitStore.deleteHabit(habit)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                    .listRowBackground(Color.clear)
                }
            }
        } header: {
            Text("All Habits")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .textCase(nil)
        }
    }
    
    private func formatTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    HabitsView()
        .environmentObject(HabitStore())
} 
