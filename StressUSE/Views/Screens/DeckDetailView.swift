import SwiftUI

struct DeckDetailView: View {
    let viewModel: DeckDetailViewModel
    let onStartStressMode: () -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Button(action: onBack) {
                        Label("К наборам", systemImage: "chevron.left")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 18) {
                        Text(viewModel.deck.subjectLabel)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.8))

                        Text(viewModel.deck.title)
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(.white)

                        Text(viewModel.deck.subtitle)
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.82))

                        HStack(spacing: 12) {
                            MetricCapsule(title: "Набор", value: viewModel.cardCountText)
                            MetricCapsule(title: "Прогресс", value: viewModel.averageScoreText)
                        }
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Как работает Stress Mode")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)

                        Text(viewModel.stressRuleText)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.82))
                            .padding(18)
                            .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Фокус слабых тем")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)

                        if viewModel.topWeakTopics.isEmpty {
                            Text("После первых ошибок здесь появятся темы для повторения.")
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.78))
                                .padding(18)
                                .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                        } else {
                            ForEach(viewModel.topWeakTopics, id: \.self) { topic in
                                HStack {
                                    Text(topic)
                                        .font(.headline.weight(.semibold))
                                    Spacer()
                                    Text("\(viewModel.weakTopicStats[topic, default: 0]) ошибок")
                                        .font(.subheadline.weight(.medium))
                                }
                                .foregroundStyle(.white)
                                .padding(18)
                                .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                            }
                        }
                    }

                    if viewModel.deck.cards.isEmpty {
                        Text("Набор пуст. Добавь карточки, чтобы активировать стресс-сессию.")
                            .font(.body.weight(.medium))
                            .foregroundStyle(.white)
                            .padding(18)
                            .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }

                    Button(action: onStartStressMode) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Запустить Stress Mode")
                                    .font(.headline.weight(.bold))
                                Text("20 минут, без паузы, с фоновым шумом")
                                    .font(.subheadline)
                                    .foregroundStyle(.black.opacity(0.7))
                            }

                            Spacer()

                            Image(systemName: "play.fill")
                                .font(.title3.weight(.bold))
                        }
                        .padding(20)
                        .foregroundStyle(.black)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.deck.cards.isEmpty)
                    .opacity(viewModel.deck.cards.isEmpty ? 0.5 : 1)
                }
                .padding(20)
            }
        }
    }
}
