import SwiftUI

struct HomeView: View {
    let decks: [QuestionDeck]
    let history: [SessionRecord]
    let weakTopicStats: [String: Int]
    let onSelectDeck: (QuestionDeck) -> Void
    let onCreateDeck: () -> Void

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Стресс ЕГЭ")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Наборы собраны как экзаменационные варианты: в одном сете несколько тем, чтобы тренировать переключение и темп.")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.82))
                    }
                    .padding(.top, 12)

                    HStack(spacing: 12) {
                        MetricCapsule(title: "Всего наборов", value: "\(decks.count)")
                        MetricCapsule(title: "Темы с ошибками", value: "\(weakTopicStats.filter { $0.value > 0 }.count)")
                    }

                    Button(action: onCreateDeck) {
                        HStack(spacing: 14) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(Color(hex: "#2563EB"))

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Создать свой набор")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(Color.black.opacity(0.86))
                                Text("Выбери предмет, добавь свои вопросы и тренируйся по ним как по обычному stress-сету.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.black.opacity(0.62))
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.black.opacity(0.35))
                        }
                        .padding(18)
                        .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Наборы")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)

                        ForEach(decks) { deck in
                            DeckCardView(
                                deck: deck,
                                weakTopicCount: deck.cards.filter { weakTopicStats[$0.topic, default: 0] > 0 }.count,
                                onTap: { onSelectDeck(deck) }
                            )
                        }
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Последние попытки")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)

                        if history.isEmpty {
                            emptyHistoryCard
                        } else {
                            ForEach(history.prefix(4)) { record in
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(record.deckTitle)
                                            .font(.headline.weight(.semibold))
                                            .foregroundStyle(Color.black.opacity(0.86))
                                        Text(record.completedAt.formatted(date: .abbreviated, time: .shortened))
                                            .font(.subheadline)
                                            .foregroundStyle(Color.black.opacity(0.52))
                                    }

                                    Spacer()

                                    Text("\(record.correctAnswers)/\(record.totalQuestions)")
                                        .font(.headline.weight(.bold))
                                        .foregroundStyle(Color.black.opacity(0.82))
                                }
                                .padding(18)
                                .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
    }

    private var emptyHistoryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("История пока пустая")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.black.opacity(0.86))
            Text("После первой стресс-сессии здесь появятся результаты и слабые темы.")
                .font(.subheadline)
                .foregroundStyle(Color.black.opacity(0.6))
        }
        .padding(18)
        .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

#Preview {
    HomeView(
        decks: DeckRepository().loadDecks(),
        history: [],
        weakTopicStats: [:],
        onSelectDeck: { _ in },
        onCreateDeck: {}
    )
}
