import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Bindable var premiumAccess: PremiumAccessService
    @AppStorage("stressuse.shuffleQuestions") private var shuffleQuestions = true
    @AppStorage("stressuse.keepStressSound") private var keepStressSound = true
    @AppStorage("stressuse.showHints") private var showHints = true
    @AppStorage("stressuse.customStressSoundName") private var customStressSoundName = ""
    @AppStorage("stressuse.customStressSoundPath") private var customStressSoundPath = ""
    @State private var isImportingStressSound = false
    @State private var soundImportMessage: String?
    let onOpenPremium: () -> Void
    let onRestorePurchases: () -> Void

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Настройки")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    premiumSettingsCard

                    VStack(alignment: .leading, spacing: 18) {
                        settingsToggle(
                            title: "Перемешивать вопросы",
                            subtitle: "Меняет порядок карточек перед запуском тренировки.",
                            isOn: $shuffleQuestions
                        )

                        settingsToggle(
                            title: "Stress Mode",
                            subtitle: "Фоновая запись аудитории во время стресс-сессии остаётся активной.",
                            isOn: premiumStressSoundBinding,
                            isEnabled: premiumAccess.hasPremiumAccess
                        )

                        customSoundControls

                        settingsToggle(
                            title: "Показывать подсказки",
                            subtitle: "Короткая подсказка под вопросом на экране сессии.",
                            isOn: $showHints
                        )
                    }
                    .padding(22)
                    .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 28, style: .continuous))

                    NavigationLink {
                        PublicOfferView()
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "doc.text.fill")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(Color(hex: "#2563EB"))
                                .frame(width: 38, height: 38)
                                .background(Color.black.opacity(0.06), in: Circle())

                            Text("Договор Публичной Оферты")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(Color.black.opacity(0.86))

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Color.black.opacity(0.42))
                        }
                        .padding(18)
                        .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
            }
        }
        .fileImporter(
            isPresented: $isImportingStressSound,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: false,
            onCompletion: handleStressSoundImport
        )
    }

    @ViewBuilder
    private func settingsToggle(title: String, subtitle: String, isOn: Binding<Bool>, isEnabled: Bool = true) -> some View {
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
                    .disabled(!isEnabled)
            }
        }
        .opacity(isEnabled ? 1 : 0.48)
    }

    private var premiumStressSoundBinding: Binding<Bool> {
        Binding(
            get: { premiumAccess.hasPremiumAccess && keepStressSound },
            set: { newValue in
                guard premiumAccess.hasPremiumAccess else { return }
                keepStressSound = newValue
            }
        )
    }

    private var customSoundControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "waveform")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color(hex: "#2563EB"))
                    .frame(width: 34, height: 34)
                    .background(Color.black.opacity(0.06), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("Свой звук для Stress Mode")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.black.opacity(0.86))

                    Text(customStressSoundName.isEmpty ? "По умолчанию используется стандартный звук атмосферы класса." : customStressSoundName)
                        .font(.subheadline)
                        .foregroundStyle(Color.black.opacity(0.58))
                }

                Spacer()
            }

            HStack(spacing: 10) {
                Button(action: { isImportingStressSound = true }) {
                    Label("Выбрать звук", systemImage: "folder.fill")
                        .font(.subheadline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(.white)
                        .background(Color(hex: "#2563EB"), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(!premiumAccess.hasPremiumAccess)
                .opacity(premiumAccess.hasPremiumAccess ? 1 : 0.48)

                if !customStressSoundPath.isEmpty {
                    Button(action: resetCustomStressSound) {
                        Image(systemName: "xmark")
                            .font(.subheadline.weight(.bold))
                            .frame(width: 46, height: 46)
                            .foregroundStyle(Color.black.opacity(0.72))
                            .background(Color.black.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }

            if !premiumAccess.hasPremiumAccess {
                Text("Доступно в Premium.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.black.opacity(0.48))
            } else if let soundImportMessage {
                Text(soundImportMessage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.black.opacity(0.48))
            }
        }
        .padding(.top, 2)
    }

    private var premiumSettingsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: premiumAccess.hasPremiumAccess ? "crown.fill" : "lock.fill")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color(hex: "#F97316"))
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.06), in: Circle())

                VStack(alignment: .leading, spacing: 6) {
                    Text(premiumAccess.statusTitle)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.black.opacity(0.86))
                    Text(premiumAccess.statusSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.black.opacity(0.6))
                }
            }

            if !premiumAccess.hasPremiumAccess {
                Button(action: onOpenPremium) {
                    HStack {
                        Image(systemName: "creditcard.fill")
                        Text(premiumAccess.primaryActionTitle)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(16)
                    .background(Color(hex: "#2563EB"), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
            } else {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                    Text("Доступ открыт")
                    Spacer()
                }
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .padding(16)
                .background(Color(hex: "#16A34A"), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            if !premiumAccess.hasPremiumAccess {
                Button(action: onRestorePurchases) {
                    Text("Восстановить покупки")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.black.opacity(0.56))
                }
                .buttonStyle(.plain)
            }

            #if DEBUG
            if premiumAccess.isDebugPremiumOverrideEnabled {
                Button(action: { premiumAccess.resetDebugPremiumOverride() }) {
                    Text("Сбросить тестовый premium")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.black.opacity(0.56))
                }
                .buttonStyle(.plain)
            }
            #endif
        }
        .padding(22)
        .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func handleStressSoundImport(_ result: Result<[URL], Error>) {
        do {
            guard let sourceURL = try result.get().first else { return }
            let didStartAccessing = sourceURL.startAccessingSecurityScopedResource()
            defer {
                if didStartAccessing {
                    sourceURL.stopAccessingSecurityScopedResource()
                }
            }

            let copiedURL = try copyStressSoundToAppSupport(from: sourceURL)
            customStressSoundPath = copiedURL.path
            customStressSoundName = sourceURL.lastPathComponent
            soundImportMessage = "Звук сохранён для следующих stress-сессий."
        } catch {
            soundImportMessage = "Не удалось сохранить звук. Попробуй другой аудиофайл."
        }
    }

    private func copyStressSoundToAppSupport(from sourceURL: URL) throws -> URL {
        let fileManager = FileManager.default
        let appSupportURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let soundsDirectory = appSupportURL.appendingPathComponent("StressSounds", isDirectory: true)
        try fileManager.createDirectory(at: soundsDirectory, withIntermediateDirectories: true)

        let fileExtension = sourceURL.pathExtension.isEmpty ? "audio" : sourceURL.pathExtension
        let destinationURL = soundsDirectory.appendingPathComponent("CustomStressSound.\(fileExtension)")

        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }

        try fileManager.copyItem(at: sourceURL, to: destinationURL)
        return destinationURL
    }

    private func resetCustomStressSound() {
        if !customStressSoundPath.isEmpty {
            try? FileManager.default.removeItem(atPath: customStressSoundPath)
        }
        customStressSoundPath = ""
        customStressSoundName = ""
        soundImportMessage = "Вернули стандартную атмосферу класса."
    }
}

#Preview {
    SettingsView(
        premiumAccess: PremiumAccessService(),
        onOpenPremium: {},
        onRestorePurchases: {}
    )
}
