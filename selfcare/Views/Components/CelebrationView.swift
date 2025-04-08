import SwiftUI

struct CelebrationView: View {
    let title: String
    let message: String
    let icon: String
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
                .symbolEffect(.bounce)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Awesome!") {
                withAnimation {
                    isPresented = false
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(30)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentColor, lineWidth: 2)
        )
        .frame(maxWidth: 300)
        .transition(.scale.combined(with: .opacity))
    }
}

struct ConfettiView: View {
    @State private var particles: [(id: Int, position: CGPoint, color: Color)] = []
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: 8, height: 8)
                    .position(particle.position)
            }
        }
        .onAppear {
            startConfetti()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startConfetti() {
        var id = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
            let newParticle = (
                id: id,
                position: CGPoint(x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                y: -20),
                color: colors.randomElement()!
            )
            particles.append(newParticle)
            id += 1
            
            // Animate particles
            withAnimation(.easeIn(duration: 2)) {
                for i in particles.indices {
                    particles[i].position.y += UIScreen.main.bounds.height + 40
                }
            }
            
            // Remove off-screen particles
            particles = particles.filter { $0.position.y < UIScreen.main.bounds.height }
        }
    }
} 