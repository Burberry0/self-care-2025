import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var habitStore: HabitStore
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink {
                        UserProfileView()
                    } label: {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text("User Profile")
                        }
                    }
                    
                    NavigationLink {
                        NotificationsView()
                    } label: {
                        HStack {
                            Image(systemName: "bell.fill")
                                .font(.title2)
                                .foregroundColor(.orange)
                            Text("Notifications")
                        }
                    }
                    
                    NavigationLink {
                        AppearanceView()
                    } label: {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .font(.title2)
                                .foregroundColor(.purple)
                            Text("Appearance")
                        }
                    }
                }
                
                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text("About")
                        }
                    }
                    
                    NavigationLink {
                        HelpView()
                    } label: {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text("Help & Support")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

struct UserProfileView: View {
    var body: some View {
        Text("User Profile Settings")
            .navigationTitle("User Profile")
    }
}

struct NotificationsView: View {
    var body: some View {
        Text("Notification Settings")
            .navigationTitle("Notifications")
    }
}

struct AppearanceView: View {
    var body: some View {
        Text("Appearance Settings")
            .navigationTitle("Appearance")
    }
}

struct AboutView: View {
    var body: some View {
        Text("About SelfCare")
            .navigationTitle("About")
    }
}

struct HelpView: View {
    var body: some View {
        Text("Help & Support")
            .navigationTitle("Help")
    }
} 