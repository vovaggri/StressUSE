import SwiftUI

struct SettingsView: View {
    @AppStorage("stressuse.shuffleQuestions") private var shuffleQuestions = true
    @AppStorage("stressuse.keepStressSound") private var keepStressSound = true
    @AppStorage("stressuse.showHints") private var showHints = true

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Настройки")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    VStack(alignment: .leading, spacing: 18) {
                        settingsToggle(
                            title: "Перемешивать вопросы",
                            subtitle: "Меняет порядок карточек перед запуском тренировки.",
                            isOn: $shuffleQuestions
                        )

                        settingsToggle(
                            title: "Стресс-шум включён",
                            subtitle: "Фоновый шум во время стресс-сессии остаётся активным.",
                            isOn: $keepStressSound
                        )

                        settingsToggle(
                            title: "Показывать подсказки",
                            subtitle: "Короткая подсказка под вопросом на экране сессии.",
                            isOn: $showHints
                        )
                    }
                    .padding(22)
                    .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 28, style: .continuous))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("MVP scope")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                        Text("Сейчас таймер зафиксирован на 20 минут, а режим сосредоточен на закрытых тестовых вопросах с несколькими правильными ответами.")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.82))
                    }
                    .padding(20)
                    .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
                .padding(20)
            }
        }
    }

    @ViewBuilder
    private func settingsToggle(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.black.opacity(0.86))
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.black.opacity(0.58))
                }

                Spacer()

                Toggle("", isOn: isOn)
                    .labelsHidden()
            }
        }
    }
}

#Preview {
    SettingsView()
}
