import SwiftUI

struct StressSessionView: View {
    @AppStorage("stressuse.showHints") private var showHints = true
    @Bindable var viewModel: StressSessionViewModel
    let onExit: () -> Void

    var body: some View {
        ZStack {
            stressBackground

            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.deck.title)
                            .font(.title2.weight(.black))
                            .foregroundStyle(.white)
                        Text(viewModel.progressText)
                            .font(.headline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.78))
                    }

                    Spacer()

                    Button(action: onExit) {
                        Image(systemName: "xmark")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(14)
                            .background(.white.opacity(0.12), in: Circle())
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: 12) {
                    MetricCapsule(title: "Осталось", value: viewModel.formattedTimeRemaining)
                    MetricCapsule(title: "Прошло", value: viewModel.formattedElapsedTime)
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text(viewModel.currentCard.topic.uppercased())
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(.orange)

                    Text(viewModel.currentCard.prompt)
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    if showHints {
                        Text(viewModel.currentCard.hint)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.72))
                    }
                }
                .padding(22)
                .background(.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 28, style: .continuous))

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.currentCard.options) { option in
                            OptionTileView(
                                option: option,
                                isSelected: viewModel.selectedOptionIDs.contains(option.id),
                                action: { viewModel.toggleSelection(for: option.id) }
                            )
                        }
                    }
                }

                Button(action: viewModel.submitAnswer) {
                    Text("Ответить и дальше")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(viewModel.canSubmit ? Color.white : Color.white.opacity(0.35))
                        .foregroundStyle(.black.opacity(viewModel.canSubmit ? 1 : 0.55))
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.canSubmit)
            }
            .padding(20)
        }
        .interactiveDismissDisabled()
        .alert("Выйти из Stress Mode?", isPresented: $viewModel.showExitConfirmation) {
            Button("Продолжить", role: .cancel) {
                viewModel.dismissExitConfirmation()
            }
            Button("Выйти", role: .destructive) {
                viewModel.confirmExit()
            }
        } message: {
            Text("Все неотвеченные вопросы будут засчитаны как ошибки.")
        }
    }

    private var stressBackground: some View {
        LinearGradient(
            colors: [
                Color(hex: "#111827"),
                Color(hex: "#7C2D12"),
                Color(hex: "#1F2937")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(Color.orange.opacity(0.22))
                .frame(width: 260, height: 260)
                .blur(radius: 40)
                .offset(x: 60, y: -70)
        }
        .ignoresSafeArea()
    }
}
