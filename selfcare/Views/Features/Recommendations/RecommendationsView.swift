import SwiftUI

struct RecommendationsView: View {
    @EnvironmentObject var recommendationStore: RecommendationStore
    @EnvironmentObject var moodStore: MoodStore
    @State private var selectedTimeRange: TimeRange = .anytime
    @State private var showingFeedbackSheet = false
    @State private var selectedRecommendation: Recommendation?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Range Picker
                    Picker("Time of Day", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Personalized Recommendations
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Personalized Recommendations")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(recommendationStore.getPersonalizedRecommendations(for: selectedTimeRange)) { recommendation in
                            RecommendationCard(
                                recommendation: recommendation,
                                onFeedback: { isHelpful in
                                    selectedRecommendation = recommendation
                                    showingFeedbackSheet = true
                                }
                            )
                        }
                    }
                    
                    // Adaptive Challenge
                    if let latestMood = moodStore.moodEntries.last {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Adaptive Challenge")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            let challenge = recommendationStore.createAdaptiveChallenge(
                                basedOn: latestMood.mood,
                                activities: latestMood.activities
                            )
                            
                            RecommendationCard(
                                recommendation: challenge,
                                onFeedback: { isHelpful in
                                    selectedRecommendation = challenge
                                    showingFeedbackSheet = true
                                }
                            )
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Recommendations")
            .sheet(isPresented: $showingFeedbackSheet) {
                if let recommendation = selectedRecommendation {
                    FeedbackView(
                        recommendation: recommendation,
                        onDismiss: { showingFeedbackSheet = false }
                    )
                }
            }
        }
    }
}

struct RecommendationCard: View {
    let recommendation: Recommendation
    let onFeedback: (Bool) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: recommendation.type.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text(recommendation.title)
                        .font(.headline)
                    Text("\(recommendation.duration) min • \(recommendation.category.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Menu {
                    Button(action: { onFeedback(true) }) {
                        Label("Helpful", systemImage: "hand.thumbsup")
                    }
                    Button(action: { onFeedback(false) }) {
                        Label("Not Helpful", systemImage: "hand.thumbsdown")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                }
            }
            
            Text(recommendation.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let feedback = recommendation.feedback {
                HStack {
                    Image(systemName: feedback.isHelpful ? "hand.thumbsup.fill" : "hand.thumbsdown.fill")
                        .foregroundColor(feedback.isHelpful ? .green : .red)
                    Text(feedback.isHelpful ? "Helpful" : "Not Helpful")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct FeedbackView: View {
    @EnvironmentObject var recommendationStore: RecommendationStore
    let recommendation: Recommendation
    let onDismiss: () -> Void
    
    @State private var isHelpful = true
    @State private var comment = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Was this helpful?", isOn: $isHelpful)
                }
                
                Section {
                    TextEditor(text: $comment)
                        .frame(height: 100)
                } header: {
                    Text("Additional Feedback (Optional)")
                }
            }
            .navigationTitle("Feedback")
            .navigationBarItems(
                leading: Button("Cancel", action: onDismiss),
                trailing: Button("Submit") {
                    recommendationStore.updateFeedback(
                        for: recommendation,
                        isHelpful: isHelpful,
                        comment: comment.isEmpty ? nil : comment
                    )
                    onDismiss()
                }
            )
        }
    }
}

#Preview {
    RecommendationsView()
        .environmentObject(RecommendationStore())
        .environmentObject(MoodStore())
} 