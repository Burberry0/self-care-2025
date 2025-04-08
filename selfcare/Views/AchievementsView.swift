import SwiftUI

struct AchievementsView: View {
    @StateObject private var achievementStore = AchievementStore()
    @State private var selectedCategory: AchievementCategory?
    
    var body: some View {
        NavigationView {
            VStack {
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryButton(
                            title: "All",
                            systemImage: "star.fill",
                            isSelected: selectedCategory == nil,
                            action: { selectedCategory = nil }
                        )
                        
                        ForEach(AchievementCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                title: category.rawValue,
                                systemImage: categoryIcon(for: category),
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Achievements list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredAchievements) { achievement in
                            AchievementCard(achievement: achievement)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Achievements")
        }
    }
    
    private var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return achievementStore.achievements.filter { $0.category == category }
        }
        return achievementStore.achievements
    }
    
    private func categoryIcon(for category: AchievementCategory) -> String {
        switch category {
        case .mood:
            return "face.smiling.fill"
        case .habits:
            return "checkmark.circle.fill"
        case .consistency:
            return "flame.fill"
        case .milestones:
            return "star.fill"
        }
    }
} 