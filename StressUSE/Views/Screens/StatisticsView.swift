import SwiftUI

struct StatisticsView: View {
    let totalSessions: Int
    let totalTrainingSeconds: Int
    let averageScorePercent: Int
    let strongestSubject: String
    let recentHistory: [SessionRecord]
    let weakTopics: [(topic: String, count: Int)]

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Статистика")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    HStack(spacing: 12) {
                        MetricCapsule(title: "Сессий", value: "\(totalSessions)")
                        MetricCapsule(title: "Средний результат", value: "\(averageScorePercent)%")
                    }

                    HStack(spacing: 12) {
                        MetricCapsule(title: "Общее время", value: format(seconds: totalTrainingSeconds))
                        MetricCapsule(title: "Лучший набор", value: strongestSubject)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Последние результаты")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)

                        if recentHistory.isEmpty {
                            Text("Статистика появится после первых прохождений.")
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(18)
                                .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        } else {
                            ForEach(recentHistory.prefix(5)) { record in
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(record.deckTitle)
                                            .font(.headline.weight(.semibold))
                                        Text(record.completedAt.formatted(date: .abbreviated, time: .shortened))
                                            .font(.subheadline)
                                            .foregroundStyle(.white.opacity(0.72))
                                    }

                                    Spacer()

                                    Text("\(record.correctAnswers)/\(record.totalQuestions)")
                                        .font(.headline.weight(.bold))
                                }
                                .foregroundStyle(.white)
                                .padding(18)
                                .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Топ слабых тем")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)

                        if weakTopics.isEmpty {
                            Text("Ошибки по темам пока не накопились.")
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.8))
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
    }

    private func format(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return hours > 0 ? "\(hours)ч \(minutes)м" : "\(minutes)м"
    }
}

#Preview {
    StatisticsView(
        totalSessions: 4,
        totalTrainingSeconds: 3200,
        averageScorePercent: 68,
        strongestSubject: "Русский: вариант 1",
        recentHistory: [],
        weakTopics: [("Пунктуация", 3), ("Право", 2)]
    )
}
