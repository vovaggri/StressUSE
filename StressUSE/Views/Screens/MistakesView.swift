import SwiftUI

struct MistakesView: View {
    let mistakesDeck: QuestionDeck?
    let weakTopics: [(topic: String, count: Int)]
    let onStart: () -> Void

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Работа над ошибками")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Здесь собираются вопросы, на которых уже были ошибки или пропуски. Можно быстро вернуться именно к слабым местам.")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.82))
                    }

                    if let mistakesDeck {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(mistakesDeck.title)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.white)

                            Text(mistakesDeck.subtitle)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.84))

                            Label("\(mistakesDeck.cards.count) вопросов в повторении", systemImage: "arrow.clockwise.circle.fill")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)

                            Button(action: onStart) {
                                Text("Начать повтор")
                                    .font(.headline.weight(.bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                                    .foregroundStyle(.black)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(22)
                        .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ошибок пока нет")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(Color.black.opacity(0.88))
                            Text("После первой стресс-сессии здесь автоматически появится подборка для повторения.")
                                .font(.subheadline)
                                .foregroundStyle(Color.black.opacity(0.6))
                        }
                        .padding(20)
                        .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Частые слабые темы")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)

                        if weakTopics.isEmpty {
                            Text("Пока нет накопленной статистики по ошибкам.")
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.78))
                                .padding(18)
                                .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        } else {
                            ForEach(Array(weakTopics.enumerated()), id: \.offset) { _, item in
                                HStack {
                                    Text(item.topic)
                                        .font(.headline.weight(.semibold))
                                    Spacer()
                                    Text("\(item.count)")
                                        .font(.headline.weight(.bold))
                                }
                                .foregroundStyle(.white)
                                .padding(18)
                                .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MistakesView(
        mistakesDeck: nil,
        weakTopics: [],
        onStart: {}
    )
}
