import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    var color: Color = .accentColor
    var alignment: Alignment = .center
    
    var body: some View {
        VStack(alignment: alignment == .center ? .center : .leading, spacing: 8) {
            if alignment == .center {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(value)
                    .font(.title2)
                    .bold()
            }
        }
        .frame(maxWidth: .infinity, alignment: alignment)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 