import SwiftUI

struct AchievementCard: View {
    let achievement: Achievement
    var style: CardStyle = .default
    
    enum CardStyle {
        case `default`
        case compact
    }
    
    var body: some View {
        if style == .default {
            defaultStyle
        } else {
            compactStyle
        }
    }
    
    private var defaultStyle: some View {
        HStack(spacing: 16) {
            Image(systemName: achievement.icon)
                .font(.title)
                .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(achievement.isUnlocked ? Color.yellow.opacity(0.2) : Color(.systemGray6))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !achievement.isUnlocked {
                    ProgressView(value: achievement.progress)
                        .tint(.blue)
                } else if let date = achievement.dateUnlocked {
                    Text("Unlocked \(date.formatted(.relative(presentation: .named)))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private var compactStyle: some View {
        VStack {
            Image(systemName: achievement.icon)
                .font(.largeTitle)
                .foregroundColor(achievement.isUnlocked ? .accentColor : .secondary)
            
            Text(achievement.title)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text(achievement.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if !achievement.isUnlocked {
                ProgressView(value: Double(achievement.currentProgress),
                           total: Double(achievement.requiredProgress))
                    .progressViewStyle(.linear)
                    .frame(height: 4)
            }
        }
        .frame(width: 160)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .opacity(achievement.isUnlocked ? 1 : 0.7)
    }
} 