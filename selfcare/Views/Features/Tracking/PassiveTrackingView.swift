import SwiftUI
import CoreLocation

struct PassiveTrackingView: View {
    @StateObject private var trackingStore = PassiveTrackingStore()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Passive Tracking")) {
                    Toggle("Enable Passive Tracking", isOn: $trackingStore.isTrackingEnabled)
                        .onChange(of: trackingStore.isTrackingEnabled) { newValue in
                            if newValue {
                                trackingStore.requestPermissions()
                                trackingStore.startTracking()
                            } else {
                                trackingStore.stopTracking()
                            }
                        }
                    
                    if trackingStore.isTrackingEnabled {
                        HStack {
                            Text("Last Updated")
                            Spacer()
                            Text(trackingStore.lastUpdate, style: .time)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Screen Time")) {
                    HStack {
                        Text("Today's Screen Time")
                        Spacer()
                        Text(formatTimeInterval(trackingStore.getDailyScreenTime()))
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Location Data")) {
                    NavigationLink("View Location History") {
                        LocationHistoryView(trackingStore: trackingStore)
                    }
                    
                    NavigationLink("Most Visited Places") {
                        MostVisitedPlacesView(trackingStore: trackingStore)
                    }
                }
                
                Section(footer: Text("Passive tracking helps provide personalized recommendations based on your daily routine and habits.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Passive Tracking")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        return String(format: "%02d:%02d", hours, minutes)
    }
}

struct LocationHistoryView: View {
    @ObservedObject var trackingStore: PassiveTrackingStore
    
    var body: some View {
        List {
            ForEach(trackingStore.getLocationHistory(for: Date()), id: \.timestamp) { location in
                VStack(alignment: .leading) {
                    Text(location.timestamp, style: .time)
                        .font(.headline)
                    Text("Lat: \(location.coordinate.latitude), Long: \(location.coordinate.longitude)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Location History")
    }
}

struct MostVisitedPlacesView: View {
    @ObservedObject var trackingStore: PassiveTrackingStore
    
    var body: some View {
        List {
            ForEach(trackingStore.getMostVisitedLocations(), id: \.location) { place in
                VStack(alignment: .leading) {
                    Text("Visited \(place.count) times")
                        .font(.headline)
                    Text("Lat: \(place.location.coordinate.latitude), Long: \(place.location.coordinate.longitude)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Most Visited Places")
    }
} 