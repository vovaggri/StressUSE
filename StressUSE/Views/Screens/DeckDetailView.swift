import SwiftUI

struct DeckDetailView: View {
    @AppStorage("stressuse.keepStressSound") private var keepStressSound = true
    let viewModel: DeckDetailViewModel
    let premiumAccess: PremiumAccessService
    let onStartStressMode: (Int) -> Void
    let onBack: () -> Void
    @State private var selectedDurationMinutes = 20

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
                        Text(isStressModeEnabled ? "Как работает Stress Mode" : "Как работает тест")
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

                    durationPicker

                    Button(action: { onStartStressMode(selectedDurationMinutes) }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(isStressModeEnabled ? "Запустить Stress Mode" : "Запустить тест")
                                    .font(.headline.weight(.bold))
                                Text(isStressModeEnabled ? "\(formattedDuration), со звуком" : "\(formattedDuration), без звука")
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

    private var durationPicker: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Длительность сессии")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Text("От 10 минут до 3 часов 55 минут")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.68))
                }

                Spacer()

                Text(formattedDuration)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.white.opacity(0.12), in: Capsule())
            }

            Slider(value: durationSliderValue, in: 10...235, step: 5)
                .tint(.orange)

            HStack {
                Text("10 мин")
                Spacer()
                Text("3 ч 55 мин")
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(.white.opacity(0.62))
        }
        .padding(18)
        .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var isStressModeEnabled: Bool {
        premiumAccess.hasPremiumAccess && keepStressSound
    }

    private var durationSliderValue: Binding<Double> {
        Binding(
            get: { Double(selectedDurationMinutes) },
            set: { selectedDurationMinutes = Int($0) }
        )
    }

    private var formattedDuration: String {
        let hours = selectedDurationMinutes / 60
        let minutes = selectedDurationMinutes % 60

        if hours == 0 {
            return "\(minutes) мин"
        }
        if minutes == 0 {
            return "\(hours) ч"
        }
        return "\(hours) ч \(minutes) мин"
    }
}
