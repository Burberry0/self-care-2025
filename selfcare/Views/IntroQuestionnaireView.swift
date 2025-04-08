import SwiftUI

struct IntroQuestionnaireView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentStep = 0
    @State private var name = ""
    @State private var email = ""
    @State private var primaryGoal: PrimaryGoal = .stressRelief
    @State private var typicalMood: TypicalMood = .mostlyPositive
    @State private var selectedEmotions: Set<Emotion> = []
    @State private var selectedActivities: Set<SelfCareActivity> = []
    @State private var preferredActivityType: ActivityType = .reflective
    @State private var preferredTime: TimeOfDay = .morning
    @State private var scheduleBasedRecommendations = true
    @State private var averageSleepHours = 7.0
    @State private var exerciseFrequency: ExerciseFrequency = .sometimes
    @State private var dietRating: DietRating = .balanced
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Progress bar
                HStack {
                    Button("Back") {
                        withAnimation {
                            if currentStep > 0 {
                                currentStep -= 1
                            }
                        }
                    }
                    .opacity(currentStep > 0 ? 1 : 0)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(Color(.systemGray5))
                            
                            Rectangle()
                                .foregroundColor(.green)
                                .frame(width: geometry.size.width * (CGFloat(currentStep) / 8))
                        }
                        .cornerRadius(10)
                    }
                    .frame(height: 8)
                    
                    Button("Skip") {
                        withAnimation {
                            currentStep = 8
                        }
                    }
                }
                .padding(.horizontal)
                
                // Content based on current step
                Group {
                    switch currentStep {
                    case 0:
                        nameStep
                    case 1:
                        goalsStep
                    case 2:
                        moodStep
                    case 3:
                        emotionsStep
                    case 4:
                        selfCareActivitiesStep
                    case 5:
                        selfCareTypesStep
                    case 6:
                        scheduleStep
                    case 7:
                        physicalHealthStep
                    default:
                        completionStep
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
                
                Spacer()
                
                // Next button
                Button(currentStep == 8 ? "Get Started" : "Next") {
                    withAnimation {
                        if currentStep < 8 {
                            currentStep += 1
                        } else {
                            completeQuestionnaire()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(currentStep == 0 && (name.isEmpty || email.isEmpty))
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
    
    private var nameStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Let's get to know you")
                .font(.title2)
                .bold()
            
            VStack(alignment: .leading, spacing: 15) {
                Text("What's your name?")
                    .font(.headline)
                
                TextField("Enter your name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
                
                Text("What's your email?")
                    .font(.headline)
                
                TextField("Enter your email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
            }
        }
        .padding()
    }
    
    private var goalsStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What's your main goal?")
                .font(.title)
                .bold()
            
            Button {
                // Show help sheet or tooltip
            } label: {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(.secondary)
                    Text("How will this help me?")
                        .underline()
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(spacing: 12) {
                GoalBubble(
                    title: "Stress Relief",
                    subtitle: "Find peace and calm in your daily life",
                    isSelected: primaryGoal == .stressRelief,
                    icons: ["🧘‍♀️", "🌿", "💆‍♀️"]
                ) {
                    primaryGoal = .stressRelief
                }
                
                GoalBubble(
                    title: "Focus",
                    subtitle: "Improve concentration and productivity",
                    isSelected: primaryGoal == .focus,
                    icons: ["🎯", "💡", "📚"]
                ) {
                    primaryGoal = .focus
                }
                
                GoalBubble(
                    title: "Emotional Resilience",
                    subtitle: "Build strength to handle life's ups and downs",
                    isSelected: primaryGoal == .emotionalResilience,
                    icons: ["💪", "🌈", "🛡️"]
                ) {
                    primaryGoal = .emotionalResilience
                }
                
                GoalBubble(
                    title: "Better Sleep",
                    subtitle: "Develop healthy sleep patterns",
                    isSelected: primaryGoal == .betterSleep,
                    icons: ["😴", "🌙", "✨"]
                ) {
                    primaryGoal = .betterSleep
                }
                
                GoalBubble(
                    title: "Improving Habits",
                    subtitle: "Create positive daily routines",
                    isSelected: primaryGoal == .improvingHabits,
                    icons: ["⭐", "📝", "🎯"]
                ) {
                    primaryGoal = .improvingHabits
                }
            }
        }
        .padding()
    }
    
    private struct GoalBubble: View {
        let title: String
        let subtitle: String
        let isSelected: Bool
        let icons: [String]
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .bold()
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: -8) {
                        ForEach(icons, id: \.self) { icon in
                            Circle()
                                .fill(.white)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Text(icon)
                                        .font(.body)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        }
                    }
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .green : .gray)
                        .font(.title3)
                        .padding(.leading, 8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.green : Color(.systemGray4), lineWidth: 2)
                )
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.green.opacity(0.1) : Color(.systemBackground))
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var moodStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your Mood")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("How would you describe your typical mood?")
                    .font(.headline)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 12) {
                        MoodBubble(
                            title: "Mostly Positive",
                            emoji: "😊",
                            isSelected: typicalMood == .mostlyPositive,
                            action: { typicalMood = .mostlyPositive }
                        )
                        
                        MoodBubble(
                            title: "Up and Down",
                            emoji: "🔄",
                            isSelected: typicalMood == .upAndDown,
                            action: { typicalMood = .upAndDown }
                        )
                        
                        MoodBubble(
                            title: "Frequently Stressed",
                            emoji: "😰",
                            isSelected: typicalMood == .frequentlyStressed,
                            action: { typicalMood = .frequentlyStressed }
                        )
                        
                        MoodBubble(
                            title: "Frequently Anxious",
                            emoji: "😟",
                            isSelected: typicalMood == .frequentlyAnxious,
                            action: { typicalMood = .frequentlyAnxious }
                        )
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private struct MoodBubble: View {
        let title: String
        let emoji: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Text(emoji)
                        .font(.title2)
                        .padding(.trailing, 8)
                    
                    Text(title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .green : .gray)
                        .font(.title3)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.green : Color(.systemGray4), lineWidth: 2)
                )
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.green.opacity(0.1) : Color(.systemBackground))
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var emotionsStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Emotional Well-being")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Which emotions do you struggle with?")
                    .font(.headline)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 12) {
                        EmotionBubble(
                            title: "Anxiety",
                            emoji: "😰",
                            isSelected: selectedEmotions.contains(.anxiety),
                            action: {
                                if selectedEmotions.contains(.anxiety) {
                                    selectedEmotions.remove(.anxiety)
                                } else {
                                    selectedEmotions.insert(.anxiety)
                                }
                            }
                        )
                        
                        EmotionBubble(
                            title: "Sadness",
                            emoji: "😢",
                            isSelected: selectedEmotions.contains(.sadness),
                            action: {
                                if selectedEmotions.contains(.sadness) {
                                    selectedEmotions.remove(.sadness)
                                } else {
                                    selectedEmotions.insert(.sadness)
                                }
                            }
                        )
                        
                        EmotionBubble(
                            title: "Overwhelm",
                            emoji: "😫",
                            isSelected: selectedEmotions.contains(.overwhelm),
                            action: {
                                if selectedEmotions.contains(.overwhelm) {
                                    selectedEmotions.remove(.overwhelm)
                                } else {
                                    selectedEmotions.insert(.overwhelm)
                                }
                            }
                        )
                        
                        EmotionBubble(
                            title: "Frustration",
                            emoji: "😤",
                            isSelected: selectedEmotions.contains(.frustration),
                            action: {
                                if selectedEmotions.contains(.frustration) {
                                    selectedEmotions.remove(.frustration)
                                } else {
                                    selectedEmotions.insert(.frustration)
                                }
                            }
                        )
                        
                        EmotionBubble(
                            title: "Lack of Motivation",
                            emoji: "😔",
                            isSelected: selectedEmotions.contains(.lackOfMotivation),
                            action: {
                                if selectedEmotions.contains(.lackOfMotivation) {
                                    selectedEmotions.remove(.lackOfMotivation)
                                } else {
                                    selectedEmotions.insert(.lackOfMotivation)
                                }
                            }
                        )
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private struct EmotionBubble: View {
        let title: String
        let emoji: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Text(emoji)
                        .font(.title2)
                        .padding(.trailing, 8)
                    
                    Text(title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .gray)
                        .font(.title3)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.blue : Color(.systemGray4), lineWidth: 2)
                )
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var selfCareActivitiesStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Self-Care Activities")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Which activities do you enjoy?")
                    .font(.headline)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ActivityBubble(
                            title: "Meditation",
                            emoji: "🧘‍♀️",
                            isSelected: selectedActivities.contains(.meditation),
                            action: {
                                if selectedActivities.contains(.meditation) {
                                    selectedActivities.remove(.meditation)
                                } else {
                                    selectedActivities.insert(.meditation)
                                }
                            }
                        )
                        
                        ActivityBubble(
                            title: "Deep Breathing",
                            emoji: "🌬️",
                            isSelected: selectedActivities.contains(.deepBreathing),
                            action: {
                                if selectedActivities.contains(.deepBreathing) {
                                    selectedActivities.remove(.deepBreathing)
                                } else {
                                    selectedActivities.insert(.deepBreathing)
                                }
                            }
                        )
                        
                        ActivityBubble(
                            title: "Journaling",
                            emoji: "📝",
                            isSelected: selectedActivities.contains(.journaling),
                            action: {
                                if selectedActivities.contains(.journaling) {
                                    selectedActivities.remove(.journaling)
                                } else {
                                    selectedActivities.insert(.journaling)
                                }
                            }
                        )
                        
                        ActivityBubble(
                            title: "Walking",
                            emoji: "🚶‍♀️",
                            isSelected: selectedActivities.contains(.walking),
                            action: {
                                if selectedActivities.contains(.walking) {
                                    selectedActivities.remove(.walking)
                                } else {
                                    selectedActivities.insert(.walking)
                                }
                            }
                        )
                        
                        ActivityBubble(
                            title: "Reading",
                            emoji: "📚",
                            isSelected: selectedActivities.contains(.reading),
                            action: {
                                if selectedActivities.contains(.reading) {
                                    selectedActivities.remove(.reading)
                                } else {
                                    selectedActivities.insert(.reading)
                                }
                            }
                        )
                        
                        ActivityBubble(
                            title: "Listening to Music",
                            emoji: "🎵",
                            isSelected: selectedActivities.contains(.music),
                            action: {
                                if selectedActivities.contains(.music) {
                                    selectedActivities.remove(.music)
                                } else {
                                    selectedActivities.insert(.music)
                                }
                            }
                        )
                        
                        ActivityBubble(
                            title: "Socializing",
                            emoji: "👥",
                            isSelected: selectedActivities.contains(.socializing),
                            action: {
                                if selectedActivities.contains(.socializing) {
                                    selectedActivities.remove(.socializing)
                                } else {
                                    selectedActivities.insert(.socializing)
                                }
                            }
                        )
                        
                        ActivityBubble(
                            title: "Creative Activities",
                            emoji: "🎨",
                            isSelected: selectedActivities.contains(.creative),
                            action: {
                                if selectedActivities.contains(.creative) {
                                    selectedActivities.remove(.creative)
                                } else {
                                    selectedActivities.insert(.creative)
                                }
                            }
                        )
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private struct ActivityBubble: View {
        let title: String
        let emoji: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Text(emoji)
                        .font(.title2)
                        .padding(.trailing, 8)
                    
                    Text(title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .purple : .gray)
                        .font(.title3)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.purple : Color(.systemGray4), lineWidth: 2)
                )
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.purple.opacity(0.1) : Color(.systemBackground))
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var selfCareTypesStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Activity Preferences")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Do you prefer activities that are:")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    ActivityTypeBubble(
                        title: "Active",
                        emoji: "🏃‍♀️",
                        isSelected: preferredActivityType == .active,
                        action: { preferredActivityType = .active }
                    )
                    
                    ActivityTypeBubble(
                        title: "Reflective",
                        emoji: "🤔",
                        isSelected: preferredActivityType == .reflective,
                        action: { preferredActivityType = .reflective }
                    )
                    
                    ActivityTypeBubble(
                        title: "Social",
                        emoji: "👥",
                        isSelected: preferredActivityType == .social,
                        action: { preferredActivityType = .social }
                    )
                    
                    ActivityTypeBubble(
                        title: "Passive",
                        emoji: "🛋️",
                        isSelected: preferredActivityType == .passive,
                        action: { preferredActivityType = .passive }
                    )
                }
                .padding(.horizontal)
            }
        }
    }
    
    private struct ActivityTypeBubble: View {
        let title: String
        let emoji: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Text(emoji)
                        .font(.title2)
                        .padding(.trailing, 8)
                    
                    Text(title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .orange : .gray)
                        .font(.title3)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.orange : Color(.systemGray4), lineWidth: 2)
                )
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.orange.opacity(0.1) : Color(.systemBackground))
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var scheduleStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Daily Schedule")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("When are you most available for self-care?")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    TimeBubble(
                        title: "Morning",
                        emoji: "🌅",
                        isSelected: preferredTime == .morning,
                        action: { preferredTime = .morning }
                    )
                    
                    TimeBubble(
                        title: "Afternoon",
                        emoji: "☀️",
                        isSelected: preferredTime == .afternoon,
                        action: { preferredTime = .afternoon }
                    )
                    
                    TimeBubble(
                        title: "Evening",
                        emoji: "🌆",
                        isSelected: preferredTime == .evening,
                        action: { preferredTime = .evening }
                    )
                    
                    TimeBubble(
                        title: "Before Bed",
                        emoji: "🌙",
                        isSelected: preferredTime == .beforeBed,
                        action: { preferredTime = .beforeBed }
                    )
                }
                .padding(.horizontal)
                
                Toggle("Would you like schedule-based recommendations?", isOn: $scheduleBasedRecommendations)
                    .font(.headline)
                    .padding(.horizontal)
            }
        }
    }
    
    private struct TimeBubble: View {
        let title: String
        let emoji: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Text(emoji)
                        .font(.title2)
                        .padding(.trailing, 8)
                    
                    Text(title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .indigo : .gray)
                        .font(.title3)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.indigo : Color(.systemGray4), lineWidth: 2)
                )
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.indigo.opacity(0.1) : Color(.systemBackground))
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var physicalHealthStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Physical Health")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("How many hours of sleep do you get on average?")
                    .font(.headline)
                    .padding(.horizontal)
                
                Slider(value: $averageSleepHours, in: 4...12, step: 0.5)
                    .padding(.horizontal)
                Text(String(format: "%.1f hours", averageSleepHours))
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                Text("Do you exercise regularly?")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    ExerciseBubble(
                        title: "Daily",
                        emoji: "🏃‍♀️",
                        isSelected: exerciseFrequency == .daily,
                        action: { exerciseFrequency = .daily }
                    )
                    
                    ExerciseBubble(
                        title: "Sometimes",
                        emoji: "🚶‍♀️",
                        isSelected: exerciseFrequency == .sometimes,
                        action: { exerciseFrequency = .sometimes }
                    )
                    
                    ExerciseBubble(
                        title: "Rarely/Never",
                        emoji: "🛋️",
                        isSelected: exerciseFrequency == .rarely,
                        action: { exerciseFrequency = .rarely }
                    )
                }
                .padding(.horizontal)
                
                Text("How would you rate your diet?")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    DietBubble(
                        title: "Healthy",
                        emoji: "🥗",
                        isSelected: dietRating == .healthy,
                        action: { dietRating = .healthy }
                    )
                    
                    DietBubble(
                        title: "Balanced",
                        emoji: "🍽️",
                        isSelected: dietRating == .balanced,
                        action: { dietRating = .balanced }
                    )
                    
                    DietBubble(
                        title: "Unhealthy",
                        emoji: "🍔",
                        isSelected: dietRating == .unhealthy,
                        action: { dietRating = .unhealthy }
                    )
                    
                    DietBubble(
                        title: "Needs Improvement",
                        emoji: "📈",
                        isSelected: dietRating == .needsImprovement,
                        action: { dietRating = .needsImprovement }
                    )
                }
                .padding(.horizontal)
            }
        }
    }
    
    private struct ExerciseBubble: View {
        let title: String
        let emoji: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Text(emoji)
                        .font(.title2)
                        .padding(.trailing, 8)
                    
                    Text(title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .teal : .gray)
                        .font(.title3)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.teal : Color(.systemGray4), lineWidth: 2)
                )
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.teal.opacity(0.1) : Color(.systemBackground))
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private struct DietBubble: View {
        let title: String
        let emoji: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Text(emoji)
                        .font(.title2)
                        .padding(.trailing, 8)
                    
                    Text(title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .brown : .gray)
                        .font(.title3)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.brown : Color(.systemGray4), lineWidth: 2)
                )
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.brown.opacity(0.1) : Color(.systemBackground))
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var completionStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("All set!")
                .font(.title)
                .bold()
            
            Text("Let's start your journey to better well-being")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private func timeOfDayToTimeRange(_ timeOfDay: TimeOfDay) -> TimeRange {
        switch timeOfDay {
        case .morning:
            return .morning
        case .afternoon:
            return .afternoon
        case .evening:
            return .evening
        case .beforeBed:
            return .evening // Map beforeBed to evening since TimeRange doesn't have a beforeBed option
        }
    }

    private func completeQuestionnaire() {
        // Create user preferences from questionnaire data
        let preferences = UserPreferences(
            preferredActivityTimes: [timeOfDayToTimeRange(preferredTime): []],
            activityEngagement: Dictionary(uniqueKeysWithValues: selectedActivities.map { ($0.rawValue, 0.0) }),
            moodBaseline: 0.0,
            notificationPreferences: UserPreferences.NotificationPreferences(
                enabled: true,
                quietHours: UserPreferences.NotificationPreferences.QuietHours(
                    start: Calendar.current.date(from: DateComponents(hour: 22)) ?? Date(),
                    end: Calendar.current.date(from: DateComponents(hour: 7)) ?? Date()
                ),
                preferredNotificationTypes: [.activityReminder, .moodCheck]
            ),
            learningPreferences: UserPreferences.LearningPreferences(
                preferredContentTypes: [.video, .interactive],
                difficultyLevel: .beginner,
                learningStyle: .visual
            )
        )
        
        // Create user profile
        let user = User(
            name: name,
            email: email,
            preferences: preferences,
            achievements: [],
            totalHabitsCompleted: 0,
            streaks: [:],
            level: 1,
            experience: 0
        )
        
        // Save user profile
        appState.currentUser = user
        
        // Set onboarding as complete
        appState.hasCompletedOnboarding = true
    }
} 