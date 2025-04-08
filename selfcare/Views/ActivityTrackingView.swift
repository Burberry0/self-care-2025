import SwiftUI

struct ActivityTrackingView: View {
    @StateObject private var trackingManager = PassiveTrackingManager.shared
    @State private var showingPermissionAlert = false
    
    var body: some View {
        List {
            if !trackingManager.permissionsGranted {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Permissions Required")
                            .font(.headline)
                        Text("To track your activities, we need access to:")
                            .foregroundColor(.secondary)
                        
                        ForEach(Configuration.Permission.requiredPermissions, id: \.self) { permission in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                                Text(permission.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button("Grant Permissions") {
                            trackingManager.requestPermissions()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                    .padding()
                }
            }
            
            Section(header: Text("Activity Tracking")) {
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(.blue)
                    Text("Screen Time")
                    Spacer()
                    Text(formatTime(trackingManager.screenTime))
                }
                
                HStack {
                    Image(systemName: "figure.walk")
                        .foregroundColor(.green)
                    Text("Steps")
                    Spacer()
                    Text("\(trackingManager.stepCount)")
                }
                
                HStack {
                    Image(systemName: "figure.walk.motion")
                        .foregroundColor(.orange)
                    Text("Current Activity")
                    Spacer()
                    Text(trackingManager.currentActivity)
                }
            }
            
            Section(header: Text("Tracking Status")) {
                Toggle("Enable Tracking", isOn: Binding(
                    get: { trackingManager.isTracking },
                    set: { newValue in
                        if newValue && !trackingManager.permissionsGranted {
                            showingPermissionAlert = true
                        } else if newValue {
                            trackingManager.startTracking()
                        } else {
                            trackingManager.stopTracking()
                        }
                    }
                ))
                .disabled(!trackingManager.permissionsGranted)
            }
        }
        .navigationTitle("Activity Tracking")
        .alert(isPresented: $showingPermissionAlert) {
            Alert(
                title: Text("Permissions Required"),
                message: Text("Please enable location and motion permissions in Settings to use activity tracking."),
                primaryButton: .default(Text("Open Settings"), action: openSettings),
                secondaryButton: .cancel()
            )
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

#Preview {
    NavigationView {
        ActivityTrackingView()
    }
} 