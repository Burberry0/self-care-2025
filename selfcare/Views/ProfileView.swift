import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            List {
                // Profile Header
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text(appState.currentUser?.name ?? "User")
                                .font(.title2)
                                .bold()
                            Text(appState.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Quick Actions
                Section(header: Text("Quick Actions")) {
                    NavigationLink(destination: Text("Achievements")) {
                        Label("Achievements", systemImage: "trophy.fill")
                    }
                    
                    NavigationLink(destination: Text("Statistics")) {
                        Label("Statistics", systemImage: "chart.bar.fill")
                    }
                    
                    NavigationLink(destination: Text("Challenges")) {
                        Label("Challenges", systemImage: "star.fill")
                    }
                }
                
                // Preferences
                Section(header: Text("Preferences")) {
                    NavigationLink(destination: NotificationSettingsView()) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                    
                    NavigationLink(destination: PrivacySettingsView()) {
                        Label("Privacy", systemImage: "lock.fill")
                    }
                    
                    NavigationLink(destination: Text("Appearance")) {
                        Label("Appearance", systemImage: "paintbrush.fill")
                    }
                }
                
                // Support
                Section(header: Text("Support")) {
                    NavigationLink(destination: Text("Help Center")) {
                        Label("Help Center", systemImage: "questionmark.circle.fill")
                    }
                    
                    NavigationLink(destination: Text("Contact Support")) {
                        Label("Contact Support", systemImage: "envelope.fill")
                    }
                    
                    NavigationLink(destination: Text("About")) {
                        Label("About", systemImage: "info.circle.fill")
                    }
                }
                
                // Account
                Section {
                    Button(action: {}) {
                        Label("Sign Out", systemImage: "arrow.right.square.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(isPresented: $showingSettings)
            }
        }
    }
}

struct NotificationSettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var dailyReminder = true
    @State private var weeklyReport = true
    @State private var habitReminders = true
    @State private var moodReminders = true
    
    var body: some View {
        Form {
            Section(header: Text("General")) {
                Toggle("Daily Reminder", isOn: $dailyReminder)
                Toggle("Weekly Report", isOn: $weeklyReport)
            }
            
            Section(header: Text("Specific Reminders")) {
                Toggle("Habit Reminders", isOn: $habitReminders)
                Toggle("Mood Check-ins", isOn: $moodReminders)
            }
            
            Section(header: Text("Reminder Time")) {
                DatePicker("Daily Reminder Time",
                          selection: Binding(
                            get: { appState.currentUser?.preferences.dailyReminderTime ?? Date() },
                            set: { _ in }
                          ),
                          displayedComponents: .hourAndMinute)
            }
        }
        .navigationTitle("Notifications")
    }
}

struct PrivacySettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var shareHealthData = false
    @State private var shareMoodData = false
    @State private var shareHabitData = false
    
    var body: some View {
        Form {
            Section(header: Text("Data Sharing")) {
                Toggle("Share Health Data", isOn: $shareHealthData)
                Toggle("Share Mood Data", isOn: $shareMoodData)
                Toggle("Share Habit Data", isOn: $shareHabitData)
            }
            
            Section(header: Text("Data Management")) {
                NavigationLink(destination: Text("Export Data")) {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                }
                
                NavigationLink(destination: Text("Delete Account")) {
                    Label("Delete Account", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Privacy")
    }
}

struct SettingsView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account")) {
                    NavigationLink(destination: Text("Edit Profile")) {
                        Label("Edit Profile", systemImage: "person.fill")
                    }
                    
                    NavigationLink(destination: Text("Change Password")) {
                        Label("Change Password", systemImage: "key.fill")
                    }
                }
                
                Section(header: Text("App Settings")) {
                    NavigationLink(destination: Text("Language")) {
                        Label("Language", systemImage: "globe")
                    }
                    
                    NavigationLink(destination: Text("Units")) {
                        Label("Units", systemImage: "ruler")
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") { isPresented = false })
        }
    }
} 