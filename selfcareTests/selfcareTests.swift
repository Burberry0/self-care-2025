import XCTest
@testable import selfcare

final class selfcareTests: XCTestCase {
    var appState: AppState!
    var habitStore: HabitStore!
    
    override func setUp() {
        super.setUp()
        appState = AppState()
        habitStore = HabitStore()
    }
    
    override func tearDown() {
        appState = nil
        habitStore = nil
        super.tearDown()
    }
    
    func testUserCreation() {
        // Given
        let user = User(
            name: "Test User",
            email: "test@example.com",
            primaryGoal: .stressRelief,
            typicalMood: .mostlyPositive,
            emotions: [.anxiety, .stress],
            preferredActivities: [.meditation, .journaling],
            preferredActivityType: .reflective,
            preferredTime: .morning,
            scheduleBasedRecommendations: true,
            averageSleepHours: 7.5,
            exerciseFrequency: .regularly,
            dietRating: .balanced
        )
        
        // When
        appState.currentUser = user
        
        // Then
        XCTAssertEqual(appState.currentUser?.name, "Test User")
        XCTAssertEqual(appState.currentUser?.email, "test@example.com")
        XCTAssertEqual(appState.currentUser?.primaryGoal, .stressRelief)
        XCTAssertEqual(appState.currentUser?.typicalMood, .mostlyPositive)
        XCTAssertEqual(appState.currentUser?.emotions.count, 2)
        XCTAssertEqual(appState.currentUser?.preferredActivities.count, 2)
    }
    
    func testHabitCreation() {
        // Given
        let habit = Habit(
            id: UUID(),
            title: "Morning Meditation",
            description: "Start the day with mindfulness",
            category: .mindfulness,
            frequency: .daily,
            reminderTime: Date(),
            isCompleted: false,
            streak: 0
        )
        
        // When
        habitStore.addHabit(habit)
        
        // Then
        XCTAssertEqual(habitStore.habits.count, 1)
        XCTAssertEqual(habitStore.habits[0].title, "Morning Meditation")
    }
    
    func testHabitCompletion() {
        // Given
        let habit = Habit(
            id: UUID(),
            title: "Test Habit",
            description: "Test Description",
            category: .mindfulness,
            frequency: .daily,
            reminderTime: Date(),
            isCompleted: false,
            streak: 0
        )
        habitStore.addHabit(habit)
        
        // When
        habitStore.toggleHabitCompletion(habit)
        
        // Then
        XCTAssertTrue(habitStore.habits[0].isCompleted)
        XCTAssertEqual(habitStore.habits[0].streak, 1)
    }
    
    func testHabitStreakIncrement() {
        // Given
        let habit = Habit(
            id: UUID(),
            title: "Test Habit",
            description: "Test Description",
            category: .mindfulness,
            frequency: .daily,
            reminderTime: Date(),
            isCompleted: false,
            streak: 0
        )
        habitStore.addHabit(habit)
        
        // When
        habitStore.toggleHabitCompletion(habit)
        habitStore.toggleHabitCompletion(habit)
        
        // Then
        XCTAssertEqual(habitStore.habits[0].streak, 2)
    }
    
    func testHabitDeletion() {
        // Given
        let habit = Habit(
            id: UUID(),
            title: "Test Habit",
            description: "Test Description",
            category: .mindfulness,
            frequency: .daily,
            reminderTime: Date(),
            isCompleted: false,
            streak: 0
        )
        habitStore.addHabit(habit)
        
        // When
        habitStore.deleteHabit(habit)
        
        // Then
        XCTAssertTrue(habitStore.habits.isEmpty)
    }
    
    func testOnboardingState() {
        // Given
        XCTAssertFalse(appState.hasCompletedOnboarding)
        
        // When
        appState.hasCompletedOnboarding = true
        
        // Then
        XCTAssertTrue(appState.hasCompletedOnboarding)
    }
    
    func testUserDataPersistence() {
        // Given
        let user = User(
            name: "Test User",
            email: "test@example.com",
            primaryGoal: .stressRelief,
            typicalMood: .mostlyPositive,
            emotions: [.anxiety],
            preferredActivities: [.meditation],
            preferredActivityType: .reflective,
            preferredTime: .morning,
            scheduleBasedRecommendations: true,
            averageSleepHours: 7.5,
            exerciseFrequency: .regularly,
            dietRating: .balanced
        )
        
        // When
        appState.currentUser = user
        appState.saveUser()
        
        // Then
        XCTAssertNotNil(appState.currentUser)
        XCTAssertEqual(appState.currentUser?.name, "Test User")
    }
} 