import SwiftUI

struct DeckCardView: View {
    let deck: QuestionDeck
    let weakTopicCount: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(deck.subjectLabel.uppercased())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.8))

                    Spacer()

                    Image(systemName: "bolt.fill")
                        .foregroundStyle(.yellow)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(deck.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)

                    Text(deck.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.82))
                        .multilineTextAlignment(.leading)
                }

                HStack(spacing: 12) {
                    Label("\(deck.cards.count) вопросов", systemImage: "rectangle.stack.fill")
                    Label("\(weakTopicCount) слабых тем", systemImage: "exclamationmark.triangle.fill")
                }
                .font(.footnote.weight(.medium))
                .foregroundStyle(.white.opacity(0.92))
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 200, alignment: .leading)
            .background(
                LinearGradient(
                    colors: deck.gradientColors.map(Color.init(hex:)),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 18, y: 12)
        }
        .buttonStyle(.plain)
    }
}
