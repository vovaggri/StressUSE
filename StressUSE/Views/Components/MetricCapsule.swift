import SwiftUI

struct MetricCapsule: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.black.opacity(0.55))

            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.black.opacity(0.88))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
