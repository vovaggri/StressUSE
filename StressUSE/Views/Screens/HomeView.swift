import SwiftUI

struct HomeView: View {
    let decks: [QuestionDeck]
    let history: [SessionRecord]
    let weakTopicStats: [String: Int]
    let premiumAccess: PremiumAccessService
    let onSelectDeck: (QuestionDeck) -> Void
    let onCreateDeck: () -> Void
    let onDeleteDeck: (QuestionDeck) -> Void
    let onOpenPremium: () -> Void

    @State private var deckPendingDeletion: QuestionDeck?
    @State private var isShowingDeleteConfirmation = false

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    metricsSection
                    premiumCard
                    createDeckButton
                    decksSection
                    historySection
                }
                .padding(20)
            }
        }
        .alert("Удалить набор?", isPresented: $isShowingDeleteConfirmation) {
            Button("Удалить", role: .destructive) {
                if let deck = deckPendingDeletion {
                    onDeleteDeck(deck)
                }
                deckPendingDeletion = nil
            }
            Button("Отмена", role: .cancel) {
                deckPendingDeletion = nil
            }
        } message: {
            Text(deckPendingDeletion.map { "«\($0.title)» исчезнет из твоих наборов." } ?? "")
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("StressCards")
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text("Наборы собраны как экзаменационные варианты: в одном сете несколько тем, чтобы тренировать переключение и темп.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.82))
        }
        .padding(.top, 12)
    }

    private var metricsSection: some View {
        HStack(spacing: 12) {
            MetricCapsule(title: "Всего наборов", value: "\(decks.count)")
            MetricCapsule(title: "Темы с ошибками", value: "\(weakTopicCount)")
        }
    }

    private var createDeckButton: some View {
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
    }

    private var decksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Наборы")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            ForEach(decks) { deck in
                deckCard(for: deck)
            }
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Последние попытки")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            if history.isEmpty {
                emptyHistoryCard
            } else {
                ForEach(history.prefix(4)) { record in
                    historyCard(for: record)
                }
            }
        }
    }

    private var emptyHistoryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("История пока пустая")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.black.opacity(0.86))
            Text("После первой сессии здесь появятся результаты и слабые темы.")
                .font(.subheadline)
                .foregroundStyle(Color.black.opacity(0.6))
        }
        .padding(18)
        .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var premiumCard: some View {
        Button(action: onOpenPremium) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: premiumAccess.hasPremiumAccess ? "crown.fill" : "lock.fill")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color(hex: "#F97316"))
                    .frame(width: 38, height: 38)
                    .background(Color.black.opacity(0.06), in: Circle())

                VStack(alignment: .leading, spacing: 6) {
                    Text(premiumAccess.statusTitle)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.black.opacity(0.86))
                    Text(premiumAccess.statusSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.black.opacity(0.6))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.black.opacity(0.32))
            }
            .padding(18)
            .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var weakTopicCount: Int {
        weakTopicStats.filter { $0.value > 0 }.count
    }

    private func historyCard(for record: SessionRecord) -> some View {
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

    @ViewBuilder
    private func deckCard(for deck: QuestionDeck) -> some View {
        let card = DeckCardView(
            deck: deck,
            weakTopicCount: weakTopicCount(for: deck),
            onTap: { onSelectDeck(deck) }
        )

        if deck.isCustomDeck {
            card.contextMenu {
                Button(role: .destructive) {
                    deckPendingDeletion = deck
                    isShowingDeleteConfirmation = true
                } label: {
                    Label("Удалить", systemImage: "trash")
                }
            }
        } else {
            card
        }
    }

    private func weakTopicCount(for deck: QuestionDeck) -> Int {
        deck.cards.filter { weakTopicStats[$0.topic, default: 0] > 0 }.count
    }

}

#Preview {
    HomeView(
        decks: DeckRepository().loadDecks(),
        history: [],
        weakTopicStats: [:],
        premiumAccess: PremiumAccessService(),
        onSelectDeck: { _ in },
        onCreateDeck: {},
        onDeleteDeck: { _ in },
        onOpenPremium: {}
    )
}
