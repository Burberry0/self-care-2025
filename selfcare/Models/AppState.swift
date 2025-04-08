import SwiftUI

class AppState: ObservableObject {
    @Published var currentUser: User?
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    @Published var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case mood
        case habits
        case health
        case profile
    }
    
    init() {
        // Load onboarding state
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        // Load user data if available
        if let userData = UserDefaults.standard.data(forKey: "currentUser") {
            do {
                let decoder = JSONDecoder()
                let user = try decoder.decode(User.self, from: userData)
                self.currentUser = user
            } catch {
                // If decoding fails, try to migrate old data
                if let oldUserData = UserDefaults.standard.data(forKey: "currentUser"),
                   let oldUser = try? JSONDecoder().decode(User.self, from: oldUserData) {
                    self.currentUser = User.migrate(from: oldUser)
                    self.saveUser(self.currentUser!)
                }
            }
        }
    }
    
    func saveUser(_ user: User) {
        currentUser = user
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
} 