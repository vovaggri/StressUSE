import SwiftUI

struct AppBackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "#111827"),
                Color(hex: "#1D4ED8"),
                Color(hex: "#F97316")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 220, height: 220)
                    .blur(radius: 10)
                    .offset(x: -120, y: -280)

                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 240, height: 240)
                    .rotationEffect(.degrees(16))
                    .offset(x: 150, y: -120)
                    .blur(radius: 6)
            }
        }
        .ignoresSafeArea()
    }
}
