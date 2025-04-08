import SwiftUI

struct PersonalizationInsightsView: View {
    @StateObject private var viewModel: PersonalizationInsightsViewModel
    
    init(personalizationStore: PersonalizationStore, moodStore: MoodStore) {
        _viewModel = StateObject(wrappedValue: PersonalizationInsightsViewModel(
            personalizationStore: personalizationStore,
            moodStore: moodStore
        ))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Activity Insights
                    ActivityInsightsCard(viewModel: viewModel)
                    
                    // Mood Insights
                    MoodInsightsCard(viewModel: viewModel)
                    
                    // Learning Preferences
                    LearningPreferencesCard(viewModel: viewModel)
                    
                    // Notification Insights
                    NotificationInsightsCard(viewModel: viewModel)
                }
                .padding()
            }
            .navigationTitle("Personalization Insights")
        }
    }
}

// MARK: - Activity Insights Card
struct ActivityInsightsCard: View {
    @ObservedObject var viewModel: PersonalizationInsightsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity Insights")
                .font(.headline)
            
            ForEach(viewModel.activityEngagement, id: \.0) { activity, score in
                HStack {
                    Text(activity)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    // Engagement score bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(score > 0.7 ? Color.green : score > 0.4 ? Color.yellow : Color.red)
                                .frame(width: geometry.size.width * CGFloat(score), height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal, 8)
                    
                    Text(String(format: "%.0f%%", score * 100))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let optimalTime = viewModel.getOptimalTimeForActivity("Meditation") {
                Text("Best time for meditation: \(optimalTime.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Mood Insights Card
struct MoodInsightsCard: View {
    @ObservedObject var viewModel: PersonalizationInsightsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood Insights")
                .font(.headline)
            
            // Mood baseline
            HStack {
                Text("Mood Baseline")
                    .font(.subheadline)
                Spacer()
                Text(String(format: "%.1f", viewModel.moodBaseline))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Mood changes
            if !viewModel.moodChanges.isEmpty {
                Text("Recent Mood Changes")
                    .font(.subheadline)
                    .padding(.top, 8)
                
                ForEach(viewModel.moodChanges, id: \.timestamp) { change in
                    HStack {
                        Text(change.timestamp.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                        
                        Spacer()
                        
                        Text("\(change.previousMood.rawValue) → \(change.currentMood.rawValue)")
                            .font(.caption)
                            .foregroundColor(change.magnitude > 0 ? .green : .red)
                    }
                }
            }
            
            // Mood consistency
            Text("Mood Tracking Consistency: \(viewModel.moodStore.moodTrackingConsistency)%")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Learning Preferences Card
struct LearningPreferencesCard: View {
    @ObservedObject var viewModel: PersonalizationInsightsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Learning Preferences")
                .font(.headline)
            
            // Content Types
            VStack(alignment: .leading, spacing: 8) {
                Text("Preferred Content Types")
                    .font(.subheadline)
                
                ForEach(Array(viewModel.preferredContentTypes), id: \.self) { type in
                    HStack {
                        Image(systemName: iconForContentType(type))
                            .foregroundColor(.blue)
                        Text(type.rawValue)
                            .font(.caption)
                    }
                }
            }
            
            // Learning Style
            HStack {
                Text("Learning Style")
                    .font(.subheadline)
                Spacer()
                Text(viewModel.formattedLearningStyle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Difficulty Level
            HStack {
                Text("Difficulty Level")
                    .font(.subheadline)
                Spacer()
                Text(viewModel.formattedDifficultyLevel)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func iconForContentType(_ type: UserPreferences.LearningPreferences.ContentType) -> String {
        switch type {
        case .video: return "video.fill"
        case .audio: return "headphones"
        case .text: return "text.alignleft"
        case .interactive: return "hand.tap.fill"
        }
    }
}

// MARK: - Notification Insights Card
struct NotificationInsightsCard: View {
    @ObservedObject var viewModel: PersonalizationInsightsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notification Insights")
                .font(.headline)
            
            // Notification Types
            VStack(alignment: .leading, spacing: 8) {
                Text("Preferred Notification Types")
                    .font(.subheadline)
                
                ForEach(Array(viewModel.preferredNotificationTypes), id: \.self) { type in
                    HStack {
                        Image(systemName: iconForNotificationType(type))
                            .foregroundColor(.blue)
                        Text(type.rawValue)
                            .font(.caption)
                    }
                }
            }
            
            // Quiet Hours
            HStack {
                Text("Quiet Hours")
                    .font(.subheadline)
                Spacer()
                Text("\(viewModel.quietHours.start.formatted(date: .omitted, time: .shortened)) - \(viewModel.quietHours.end.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Notification Response Rate
            Text("Response Rate: \(Int(viewModel.notificationResponseRate * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func iconForNotificationType(_ type: UserPreferences.NotificationPreferences.NotificationType) -> String {
        switch type {
        case .activityReminder: return "bell.fill"
        case .moodCheck: return "face.smiling.fill"
        case .progressUpdate: return "chart.bar.fill"
        case .challengeReminder: return "star.fill"
        }
    }
} 