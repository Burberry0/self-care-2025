import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            WellnessView()
                .tabItem {
                    Label("Wellness", systemImage: "heart.fill")
                }
            
            ActivityView()
                .tabItem {
                    Label("Activity", systemImage: "figure.run")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to Self Care 2025")
                    .font(.title)
                    .padding()
                
                // Daily summary card
                VStack(alignment: .leading, spacing: 10) {
                    Text("Today's Summary")
                        .font(.headline)
                    
                    HStack {
                        VStack {
                            Text("Mood")
                            Image(systemName: "face.smiling")
                                .font(.title)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                        
                        VStack {
                            Text("Activity")
                            Image(systemName: "figure.run")
                                .font(.title)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                        
                        VStack {
                            Text("Sleep")
                            Image(systemName: "bed.double.fill")
                                .font(.title)
                        }
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Home")
        }
    }
}

struct WellnessView: View {
    var body: some View {
        NavigationView {
            Text("Wellness Tracking")
                .navigationTitle("Wellness")
        }
    }
}

struct ActivityView: View {
    var body: some View {
        NavigationView {
            Text("Activity Logging")
                .navigationTitle("Activity")
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationView {
            Text("User Profile")
                .navigationTitle("Profile")
        }
    }
}

#Preview {
    ContentView()
} 