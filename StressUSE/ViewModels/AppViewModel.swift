import Foundation
import Observation

enum AppTab: Hashable {
    case decks
    case mistakes
    case statistics
    case settings
}

@Observable
@MainActor
final class AppViewModel {
    private let deckRepository: DeckProviding
    private let persistenceService: PersistenceServicing
    private var cardsByID: [String: QuestionCard] = [:]

    var decks: [QuestionDeck] = []
    var history: [SessionRecord] = []
    var weakTopicStats: [String: Int] = [:]
    var selectedDeck: QuestionDeck?
    var activeSessionViewModel: StressSessionViewModel?
    var latestResult: SessionRecord?
    var resultDeck: QuestionDeck?
    var latestMistakesDeck: QuestionDeck?
    var selectedTab: AppTab = .decks

    init(
        deckRepository: DeckProviding = DeckRepository(),
        persistenceService: PersistenceServicing = PersistenceService()
    ) {
        self.deckRepository = deckRepository
        self.persistenceService = persistenceService
        load()
    }

    var navigationState: String {
        if activeSessionViewModel != nil { return "session" }
        if latestResult != nil { return "results" }
        if selectedDeck != nil { return "detail" }
        return "home"
    }

    func load() {
        decks = deckRepository.loadDecks()
        cardsByID = Dictionary(
            uniqueKeysWithValues: decks
                .flatMap(\.cards)
                .map { ($0.id, $0) }
        )
        history = persistenceService.loadHistory().sorted(by: { $0.completedAt > $1.completedAt })
        weakTopicStats = persistenceService.loadWeakTopicStats()
        latestMistakesDeck = buildMistakesDeck(from: history.first)
    }

    func selectDeck(_ deck: QuestionDeck) {
        latestResult = nil
        resultDeck = nil
        latestMistakesDeck = buildMistakesDeck(from: history.first)
        selectedDeck = deck
        selectedTab = .decks
    }

    func returnToLibrary() {
        activeSessionViewModel?.stopServices()
        activeSessionViewModel = nil
        selectedDeck = nil
        latestResult = nil
        resultDeck = nil
        latestMistakesDeck = buildMistakesDeck(from: history.first)
        selectedTab = .decks
    }

    func startStressMode(for deck: QuestionDeck) {
        let preparedDeck = prepareDeckForSession(deck)
        selectedDeck = preparedDeck
        latestResult = nil
        resultDeck = nil
        latestMistakesDeck = nil
        activeSessionViewModel = StressSessionViewModel(
            deck: preparedDeck,
            stressSoundEnabled: UserDefaults.standard.object(forKey: "stressuse.keepStressSound") as? Bool ?? true
        ) { [weak self] summary in
            self?.completeSession(with: summary)
        }
    }

    func handleSessionExit() {
        activeSessionViewModel?.requestExit()
    }

    func retryLastDeck() {
        guard let deck = resultDeck else { return }
        startStressMode(for: deck)
    }

    func startMistakeRecovery() {
        guard let deck = latestMistakesDeck else { return }
        startStressMode(for: deck)
    }

    func openMistakesTab() {
        selectedDeck = nil
        latestResult = nil
        resultDeck = nil
        selectedTab = .mistakes
    }

    func closeDeckDetail() {
        selectedDeck = nil
    }

    private func completeSession(with summary: SessionSummary) {
        let record = SessionRecord(
            deckID: summary.deck.id,
            deckTitle: summary.deck.title,
            startedAt: summary.startedAt,
            completedAt: summary.completedAt,
            elapsedSeconds: summary.elapsedSeconds,
            answeredQuestions: summary.answeredQuestions,
            correctAnswers: summary.correctAnswers,
            totalQuestions: summary.totalQuestions,
            missedTopics: summary.missedTopics,
            missedCardIDs: summary.missedCardIDs,
            completionReason: summary.completionReason
        )

        activeSessionViewModel?.stopServices()
        activeSessionViewModel = nil
        latestResult = record
        resultDeck = summary.deck
        selectedDeck = nil
        latestMistakesDeck = buildMistakesDeck(from: record)

        history.insert(record, at: 0)
        history = Array(history.prefix(20))
        persistenceService.saveHistory(history)

        for topic in summary.missedTopics {
            weakTopicStats[topic, default: 0] += 1
        }
        persistenceService.saveWeakTopicStats(weakTopicStats)
    }

    private func buildMistakesDeck(from record: SessionRecord?) -> QuestionDeck? {
        guard let record else { return nil }

        let cards = record.missedCardIDs
            .compactMap { cardsByID[$0] }
            .uniqued()

        guard !cards.isEmpty else { return nil }

        let subject = cards.first?.subject ?? "ЕГЭ"
        let topics = Array(Set(cards.map(\.topic))).sorted()
        let subtitle: String
        if topics.count == 1, let topic = topics.first {
            subtitle = "Повтор вопросов по теме «\(topic)» после последней стресс-сессии."
        } else {
            subtitle = "Автоматически собранный набор из вопросов, где были ошибки или пропуски."
        }

        return QuestionDeck(
            id: "mistakes-\(record.id.uuidString)",
            title: "Работа над ошибками",
            subtitle: subtitle,
            subjectLabel: subject,
            gradientColors: ["#7C3AED", "#F97316"],
            cards: Array(cards.prefix(10))
        )
    }

    var totalSessionsCount: Int {
        history.count
    }

    var totalTrainingSeconds: Int {
        history.reduce(0) { $0 + $1.elapsedSeconds }
    }

    var averageScorePercent: Int {
        guard !history.isEmpty else { return 0 }
        let average = history.map(\.scoreFraction).reduce(0, +) / Double(history.count)
        return Int(average * 100)
    }

    var strongestSubject: String {
        let grouped = Dictionary(grouping: history, by: \.deckTitle)
        let best = grouped.max { lhs, rhs in
            let left = lhs.value.map(\.scoreFraction).reduce(0, +) / Double(lhs.value.count)
            let right = rhs.value.map(\.scoreFraction).reduce(0, +) / Double(rhs.value.count)
            return left < right
        }
        return best?.key ?? "Пока нет данных"
    }

    var topWeakTopics: [(topic: String, count: Int)] {
        weakTopicStats
            .sorted { lhs, rhs in
                if lhs.value == rhs.value { return lhs.key < rhs.key }
                return lhs.value > rhs.value
            }
            .prefix(5)
            .map { ($0.key, $0.value) }
    }

    private func prepareDeckForSession(_ deck: QuestionDeck) -> QuestionDeck {
        let shouldShuffle = UserDefaults.standard.object(forKey: "stressuse.shuffleQuestions") as? Bool ?? true
        guard shouldShuffle else { return deck }

        return QuestionDeck(
            id: deck.id,
            title: deck.title,
            subtitle: deck.subtitle,
            subjectLabel: deck.subjectLabel,
            gradientColors: deck.gradientColors,
            cards: deck.cards.shuffled()
        )
    }
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
