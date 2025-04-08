import Foundation
import SwiftUI

class HealthStore: ObservableObject {
    @Published var stepsToday: Double = 0
    @Published var activeMinutesToday: Double = 0
    @Published var distanceToday: Double = 0
    @Published var activeCaloriesToday: Double = 0
    
    // Sample data for demonstration
    init() {
        // In a real app, we would request HealthKit authorization here
        loadSampleData()
    }
    
    private func loadSampleData() {
        stepsToday = Double.random(in: 5000...12000)
        activeMinutesToday = Double.random(in: 30...120)
        distanceToday = Double.random(in: 3...8)
        activeCaloriesToday = Double.random(in: 200...500)
    }
    
    func refreshData() {
        // In a real app, this would fetch actual HealthKit data
        loadSampleData()
    }
} 