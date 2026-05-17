import SwiftUI

struct PremiumOfferView: View {
    @Bindable var premiumAccess: PremiumAccessService
    let feature: PremiumFeature
    let onClose: () -> Void
    let onPurchase: () -> Void
    let onRestore: () -> Void

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Spacer()

                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white)
                                .padding(12)
                                .background(.white.opacity(0.14), in: Circle())
                        }
                        .buttonStyle(.plain)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Label("Premium-доступ", systemImage: "crown.fill")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.yellow)

                        Text(feature.title)
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundStyle(.white)

                        Text(feature.subtitle)
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.82))
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        benefitRow(icon: "timer", title: "Stress Mode", subtitle: "20 минут без пауз и автоматический зачёт пропусков.")
                        benefitRow(icon: "chart.line.uptrend.xyaxis", title: "Слабые места", subtitle: "Темы с ошибками поднимаются в статистику и повторение.")
                        benefitRow(icon: "arrow.triangle.2.circlepath", title: "Работа над ошибками", subtitle: "После сессии приложение собирает персональный набор для восстановления.")
                    }
                    .padding(20)
                    .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 28, style: .continuous))

                    VStack(alignment: .leading, spacing: 10) {
                        if premiumAccess.hasPremiumAccess {
                            Label("Доступ открыт", systemImage: "checkmark.seal.fill")
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                        } else {
                            HStack(alignment: .firstTextBaseline) {
                                Text(premiumAccess.displayPrice)
                                    .font(.system(size: 44, weight: .black, design: .rounded))
                                Text("в месяц")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.76))
                            }
                            .foregroundStyle(.white)
                        }

                        Text(premiumAccess.hasPremiumAccess ? "Stress Mode и персональная аналитика уже доступны. Оплата проходит через App Store. Отменить премиум версию можно в настройках аккаунта." : premiumAccess.hasIntroductoryTrial ? "Первые 7 дней бесплатно, затем подписка продлевается автоматически." : "Оплата проходит через App Store. Отменить премиум версию можно в настройках аккаунта.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.72))
                    }

                    VStack(spacing: 12) {
                        if premiumAccess.hasPremiumAccess {
                            Button(action: onClose) {
                                premiumButtonTitle("Готово", systemImage: "checkmark")
                            }
                            .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .foregroundStyle(.black)
                        } else {
                            Button(action: onPurchase) {
                                premiumButtonTitle(premiumAccess.primaryActionTitle, systemImage: "creditcard.fill")
                            }
                            .disabled(premiumAccess.isPurchasing)
                            .background(.white.opacity(premiumAccess.isPurchasing ? 0.5 : 1), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .foregroundStyle(.black.opacity(premiumAccess.isPurchasing ? 0.62 : 1))
                        }

                        if !premiumAccess.hasPremiumAccess {
                            Button(action: onRestore) {
                                premiumButtonTitle("Восстановить покупки", systemImage: "arrow.clockwise")
                            }
                            .background(Color(hex: "#F97316"), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .foregroundStyle(.black)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
            }
        }
    }

    private func benefitRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.headline.weight(.bold))
                .frame(width: 34, height: 34)
                .background(.white.opacity(0.16), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.bold))
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.72))
            }
        }
        .foregroundStyle(.white)
    }

    private func premiumButtonTitle(_ title: String, systemImage: String) -> some View {
        HStack {
            Image(systemName: systemImage)
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .font(.headline.weight(.bold))
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
    }
}

struct PremiumLockedView: View {
    let feature: PremiumFeature
    let premiumAccess: PremiumAccessService
    let onOpenPremium: () -> Void

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Premium", systemImage: "lock.fill")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.yellow)

                    Text(feature.title)
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text(feature.subtitle)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.82))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(premiumAccess.statusTitle)
                        .font(.title3.weight(.bold))
                    Text(premiumAccess.statusSubtitle)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.72))
                }
                .foregroundStyle(.white)
                .padding(20)
                .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                Button(action: onOpenPremium) {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text(premiumAccess.primaryActionTitle)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.headline.weight(.bold))
                    .padding(20)
                    .foregroundStyle(.black)
                    .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(20)
        }
    }
}
