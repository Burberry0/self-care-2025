import Foundation
import CoreLocation
import UIKit
import CoreMotion

class PassiveTrackingManager: NSObject, ObservableObject {
    @Published var screenTime: TimeInterval = 0
    @Published var lastLocation: CLLocation?
    @Published var stepCount: Int = 0
    @Published var isTracking: Bool = false
    @Published var currentActivity: String = "Unknown"
    @Published var permissionsGranted: Bool = false
    
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    private var screenTimeTimer: Timer?
    private var lastActiveTime: Date?
    
    static let shared = PassiveTrackingManager()
    
    override init() {
        super.init()
        setupLocationManager()
        setupScreenTimeTracking()
        checkPermissions()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.activityType = .fitness
    }
    
    private func setupScreenTimeTracking() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppStateChange),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppStateChange),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    private func checkPermissions() {
        let locationStatus = locationManager.authorizationStatus
        let motionStatus = CMMotionActivityManager.authorizationStatus()
        
        permissionsGranted = (locationStatus == .authorizedAlways || locationStatus == .authorizedWhenInUse) &&
                            motionStatus == .authorized
    }
    
    func requestPermissions() {
        locationManager.requestAlwaysAuthorization()
        
        if CMMotionActivityManager.isActivityAvailable() {
            motionManager.queryActivityStarting(from: Date(), to: Date(), to: .main) { _, _ in
                // This will trigger the permission request
            }
        }
    }
    
    func startTracking() {
        guard permissionsGranted else {
            requestPermissions()
            return
        }
        
        isTracking = true
        locationManager.startUpdatingLocation()
        
        if CMMotionActivityManager.isActivityAvailable() {
            motionManager.startActivityUpdates(to: .main) { [weak self] activity in
                guard let activity = activity else { return }
                self?.updateCurrentActivity(activity)
            }
        }
        
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: Date()) { [weak self] data, error in
                guard let data = data else { return }
                DispatchQueue.main.async {
                    self?.stepCount = data.numberOfSteps.intValue
                }
            }
        }
        
        startScreenTimeTracking()
    }
    
    func stopTracking() {
        isTracking = false
        locationManager.stopUpdatingLocation()
        motionManager.stopActivityUpdates()
        pedometer.stopUpdates()
        stopScreenTimeTracking()
    }
    
    private func startScreenTimeTracking() {
        screenTimeTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            if UIApplication.shared.applicationState == .active {
                self?.screenTime += 60
            }
        }
    }
    
    private func stopScreenTimeTracking() {
        screenTimeTimer?.invalidate()
        screenTimeTimer = nil
    }
    
    private func updateCurrentActivity(_ activity: CMMotionActivity) {
        DispatchQueue.main.async {
            if activity.stationary {
                self.currentActivity = "Stationary"
            } else if activity.walking {
                self.currentActivity = "Walking"
            } else if activity.running {
                self.currentActivity = "Running"
            } else if activity.automotive {
                self.currentActivity = "In Vehicle"
            } else if activity.cycling {
                self.currentActivity = "Cycling"
            } else {
                self.currentActivity = "Unknown"
            }
        }
    }
    
    @objc private func handleAppStateChange(_ notification: Notification) {
        if notification.name == UIApplication.didBecomeActiveNotification {
            lastActiveTime = Date()
            checkPermissions()
        } else if notification.name == UIApplication.didEnterBackgroundNotification {
            if let lastActive = lastActiveTime {
                screenTime += Date().timeIntervalSince(lastActive)
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension PassiveTrackingManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            checkPermissions()
        default:
            manager.stopUpdatingLocation()
            checkPermissions()
        }
    }
} 