import SwiftUI

struct ResultsView: View {
    let record: SessionRecord
    let deck: QuestionDeck
    let weakTopicStats: [String: Int]
    let mistakesDeck: QuestionDeck?
    let onRetry: () -> Void
    let onOpenMistakesTab: () -> Void
    let onBackToLibrary: () -> Void

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Сессия завершена")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.78))
                        Text(record.deckTitle)
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    HStack(spacing: 12) {
                        MetricCapsule(title: "Результат", value: "\(record.correctAnswers)/\(record.totalQuestions)")
                        MetricCapsule(title: "Время", value: format(seconds: record.elapsedSeconds))
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Что пошло неидеально")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)

                        if record.missedTopics.isEmpty {
                            Text("Без ошибок. Отличный контроль в стресс-режиме.")
                                .font(.body.weight(.medium))
                                .foregroundStyle(.white)
                                .padding(18)
                                .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                        } else {
                            ForEach(Array(Set(record.missedTopics)).sorted(), id: \.self) { topic in
                                HStack {
                                    Text(topic)
                                        .font(.headline.weight(.semibold))
                                    Spacer()
                                    Text("\(weakTopicStats[topic, default: 0]) раз(а)")
                                        .font(.subheadline)
                                }
                                .foregroundStyle(.white)
                                .padding(18)
                                .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                            }
                        }
                    }

                    VStack(spacing: 12) {
                        Button(action: onRetry) {
                            Text("Пройти заново")
                                .font(.headline.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .foregroundStyle(.black)
                        }
                        .buttonStyle(.plain)

                        if mistakesDeck != nil {
                            Button(action: onOpenMistakesTab) {
                                Text("Открыть работу над ошибками")
                                    .font(.headline.weight(.bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(Color.orange, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                                    .foregroundStyle(.black)
                            }
                            .buttonStyle(.plain)
                        }

                        Button(action: onBackToLibrary) {
                            Text("Выбрать другой набор")
                                .font(.headline.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
        }
        .ignoresSafeArea()
    }

    private func format(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
