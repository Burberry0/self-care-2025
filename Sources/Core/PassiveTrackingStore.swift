import Foundation
import CoreLocation
import ScreenTime
import SwiftUI

class PassiveTrackingStore: NSObject, ObservableObject {
    @Published var screenTime: TimeInterval = 0
    @Published var locationHistory: [CLLocation] = []
    @Published var isTrackingEnabled: Bool = false
    @Published var lastUpdate: Date = Date()
    
    private let locationManager = CLLocationManager()
    private let screenTimeManager = STScreenTimeManager.shared
    private let calendar = Calendar.current
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        // Load tracking state
        isTrackingEnabled = UserDefaults.standard.bool(forKey: "isPassiveTrackingEnabled")
    }
    
    func requestPermissions() {
        // Request location permissions
        locationManager.requestAlwaysAuthorization()
        
        // Request screen time permissions
        screenTimeManager.requestAuthorization { [weak self] error in
            if let error = error {
                print("Screen Time authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    func startTracking() {
        guard !isTrackingEnabled else { return }
        
        // Start location updates
        locationManager.startUpdatingLocation()
        
        // Start screen time monitoring
        startScreenTimeMonitoring()
        
        isTrackingEnabled = true
        UserDefaults.standard.set(true, forKey: "isPassiveTrackingEnabled")
    }
    
    func stopTracking() {
        guard isTrackingEnabled else { return }
        
        // Stop location updates
        locationManager.stopUpdatingLocation()
        
        // Stop screen time monitoring
        stopScreenTimeMonitoring()
        
        isTrackingEnabled = false
        UserDefaults.standard.set(false, forKey: "isPassiveTrackingEnabled")
    }
    
    private func startScreenTimeMonitoring() {
        // Start monitoring screen time
        // Implementation depends on ScreenTime framework capabilities
    }
    
    private func stopScreenTimeMonitoring() {
        // Stop monitoring screen time
        // Implementation depends on ScreenTime framework capabilities
    }
    
    // MARK: - Data Analysis
    
    func getDailyScreenTime() -> TimeInterval {
        // Calculate daily screen time
        return screenTime
    }
    
    func getLocationHistory(for date: Date) -> [CLLocation] {
        return locationHistory.filter { location in
            calendar.isDate(location.timestamp, inSameDayAs: date)
        }
    }
    
    func getMostVisitedLocations() -> [(location: CLLocation, count: Int)] {
        // Group locations by proximity and count visits
        var locationGroups: [CLLocation: Int] = [:]
        
        for location in locationHistory {
            let roundedLocation = CLLocation(
                latitude: round(location.coordinate.latitude * 100) / 100,
                longitude: round(location.coordinate.longitude * 100) / 100
            )
            locationGroups[roundedLocation, default: 0] += 1
        }
        
        return locationGroups.map { ($0.key, $0.value) }
            .sorted { $0.count > $1.count }
    }
}

// MARK: - CLLocationManagerDelegate
extension PassiveTrackingStore: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationHistory.append(contentsOf: locations)
        lastUpdate = Date()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            if isTrackingEnabled {
                manager.startUpdatingLocation()
            }
        case .denied, .restricted:
            isTrackingEnabled = false
            UserDefaults.standard.set(false, forKey: "isPassiveTrackingEnabled")
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
} 