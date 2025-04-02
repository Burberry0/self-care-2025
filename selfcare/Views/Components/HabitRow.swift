import SwiftUI

struct HabitRow: View {
    let name: String
    let category: Category
    let time: String
    let isCompleted: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isCompleted ? .green : .gray)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                HStack(spacing: 4) {
                    Image(systemName: category.icon)
                        .foregroundColor(.blue)
                        .font(.system(size: 12))
                    Text(category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(time)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
} 