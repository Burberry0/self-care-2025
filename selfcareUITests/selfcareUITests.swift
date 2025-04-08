import XCTest

final class selfcareUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITesting"]
        app.launch()
    }
    
    func testOnboardingFlow() {
        // Test name and email input
        let nameTextField = app.textFields["Enter your name"]
        XCTAssertTrue(nameTextField.exists)
        nameTextField.tap()
        nameTextField.typeText("Test User")
        
        let emailTextField = app.textFields["Enter your email"]
        XCTAssertTrue(emailTextField.exists)
        emailTextField.tap()
        emailTextField.typeText("test@example.com")
        
        // Test goal selection
        app.buttons["Next"].tap()
        XCTAssertTrue(app.staticTexts["What's your main goal?"].exists)
        
        // Select a goal
        let stressReliefButton = app.buttons["Stress Relief"]
        XCTAssertTrue(stressReliefButton.exists)
        stressReliefButton.tap()
        
        // Test mood selection
        app.buttons["Next"].tap()
        XCTAssertTrue(app.staticTexts["Your Mood"].exists)
        
        // Select mood
        let moodSegmentedControl = app.segmentedControls.firstMatch
        XCTAssertTrue(moodSegmentedControl.exists)
        moodSegmentedControl.buttons["Mostly Positive"].tap()
        
        // Test emotions selection
        app.buttons["Next"].tap()
        XCTAssertTrue(app.staticTexts["Emotional Well-being"].exists)
        
        // Select emotions
        let anxietyButton = app.buttons["Anxiety"]
        XCTAssertTrue(anxietyButton.exists)
        anxietyButton.tap()
        
        // Test self-care preferences
        app.buttons["Next"].tap()
        XCTAssertTrue(app.staticTexts["Self-Care Preferences"].exists)
        
        // Select activities
        let meditationButton = app.buttons["Meditation"]
        XCTAssertTrue(meditationButton.exists)
        meditationButton.tap()
        
        // Test schedule preferences
        app.buttons["Next"].tap()
        XCTAssertTrue(app.staticTexts["Daily Schedule"].exists)
        
        // Select time of day
        let timeSegmentedControl = app.segmentedControls.firstMatch
        XCTAssertTrue(timeSegmentedControl.exists)
        timeSegmentedControl.buttons["Morning"].tap()
        
        // Test physical health
        app.buttons["Next"].tap()
        XCTAssertTrue(app.staticTexts["Physical Health"].exists)
        
        // Set sleep hours
        let sleepSlider = app.sliders.firstMatch
        XCTAssertTrue(sleepSlider.exists)
        sleepSlider.adjust(toNormalizedSliderPosition: 0.7) // 7 hours
        
        // Complete onboarding
        app.buttons["Next"].tap()
        XCTAssertTrue(app.staticTexts["All set!"].exists)
        app.buttons["Get Started"].tap()
    }
    
    func testHabitCreation() {
        // Skip onboarding if needed
        if app.staticTexts["Let's get to know you"].exists {
            testOnboardingFlow()
        }
        
        // Navigate to habits
        let habitsTab = app.tabBars.buttons["Habits"]
        XCTAssertTrue(habitsTab.exists)
        habitsTab.tap()
        
        // Add new habit
        let addButton = app.buttons["Add Habit"]
        XCTAssertTrue(addButton.exists)
        addButton.tap()
        
        // Fill habit details
        let titleTextField = app.textFields["Habit Title"]
        XCTAssertTrue(titleTextField.exists)
        titleTextField.tap()
        titleTextField.typeText("Morning Meditation")
        
        let descriptionTextField = app.textFields["Description"]
        XCTAssertTrue(descriptionTextField.exists)
        descriptionTextField.tap()
        descriptionTextField.typeText("Start the day with mindfulness")
        
        // Select category
        let categoryButton = app.buttons["Mindfulness"]
        XCTAssertTrue(categoryButton.exists)
        categoryButton.tap()
        
        // Save habit
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()
        
        // Verify habit was created
        XCTAssertTrue(app.staticTexts["Morning Meditation"].exists)
    }
    
    func testHabitCompletion() {
        // Skip onboarding if needed
        if app.staticTexts["Let's get to know you"].exists {
            testOnboardingFlow()
        }
        
        // Create a habit if none exists
        if !app.staticTexts["Morning Meditation"].exists {
            testHabitCreation()
        }
        
        // Complete the habit
        let habitCell = app.cells["Morning Meditation"]
        XCTAssertTrue(habitCell.exists)
        habitCell.tap()
        
        // Verify completion
        let completionButton = app.buttons["Complete"]
        XCTAssertTrue(completionButton.exists)
        completionButton.tap()
        
        // Verify streak
        let streakText = app.staticTexts["Streak: 1"]
        XCTAssertTrue(streakText.exists)
    }
    
    func testProfileView() {
        // Skip onboarding if needed
        if app.staticTexts["Let's get to know you"].exists {
            testOnboardingFlow()
        }
        
        // Navigate to profile
        let profileTab = app.tabBars.buttons["Profile"]
        XCTAssertTrue(profileTab.exists)
        profileTab.tap()
        
        // Verify user information
        XCTAssertTrue(app.staticTexts["Test User"].exists)
        XCTAssertTrue(app.staticTexts["test@example.com"].exists)
        
        // Verify goal
        XCTAssertTrue(app.staticTexts["Stress Relief"].exists)
        
        // Verify mood
        XCTAssertTrue(app.staticTexts["Mostly Positive"].exists)
    }
} 