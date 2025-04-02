import SwiftUI

struct HabitsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var habitStore: HabitStore
    @State private var showingAddHabit = false
    @State private var selectedCategory: Category? = nil
    
    private var filteredHabits: [Habit] {
        if selectedCategory == nil {
            return habitStore.habits
        }
        return habitStore.habits.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8) {
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
                }
                
                // Main List
                List {
                    // Today's Habits Section
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
                    
                    // All Habits Section
                    Section {
                        if filteredHabits.isEmpty {
                            Text("No habits found")
                                .foregroundColor(.secondary)
                                .listRowBackground(Color.clear)
                        } else {
                            ForEach(filteredHabits) { habit in
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
                .listStyle(PlainListStyle())
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddHabit = true
                    } label: {
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

#Preview {
    HabitsView()
        .environmentObject(AppState())
        .environmentObject(HabitStore())
} 
