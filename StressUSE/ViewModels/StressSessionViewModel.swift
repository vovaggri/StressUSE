import Foundation
import Observation

@Observable
@MainActor
final class StressSessionViewModel {
    let deck: QuestionDeck
    let totalDuration: Int = 20 * 60
    let stressSoundEnabled: Bool

    private let timerService: SessionTimerService
    private let noiseService: StressNoiseService
    private let onComplete: (SessionSummary) -> Void

    private var isFinished = false
    private(set) var currentIndex: Int = 0
    private(set) var remainingSeconds: Int
    private(set) var correctAnswers: Int = 0
    private(set) var answeredQuestions: Int = 0
    private(set) var selectedOptionIDs: Set<String> = []
    private(set) var missedTopics: [String] = []
    private(set) var missedCardIDs: [String] = []
    private(set) var startedAt = Date()
    var showExitConfirmation = false

    init(
        deck: QuestionDeck,
        stressSoundEnabled: Bool = true,
        timerService: SessionTimerService? = nil,
        noiseService: StressNoiseService? = nil,
        onComplete: @escaping (SessionSummary) -> Void
    ) {
        self.deck = deck
        self.stressSoundEnabled = stressSoundEnabled
        self.timerService = timerService ?? SessionTimerService()
        self.noiseService = noiseService ?? StressNoiseService()
        self.onComplete = onComplete
        self.remainingSeconds = totalDuration

        startSession()
    }

    var currentCard: QuestionCard {
        deck.cards[currentIndex]
    }

    var progressText: String {
        "Вопрос \(currentIndex + 1) из \(deck.cards.count)"
    }

    var formattedTimeRemaining: String {
        Self.format(seconds: remainingSeconds)
    }

    var formattedElapsedTime: String {
        Self.format(seconds: totalDuration - remainingSeconds)
    }

    var canSubmit: Bool {
        !selectedOptionIDs.isEmpty
    }

    func toggleSelection(for optionID: String) {
        if selectedOptionIDs.contains(optionID) {
            selectedOptionIDs.remove(optionID)
        } else {
            selectedOptionIDs.insert(optionID)
        }
    }

    func submitAnswer() {
        let isCorrect = selectedOptionIDs == currentCard.correctOptionIDs
        answeredQuestions += 1

        if isCorrect {
            correctAnswers += 1
        } else {
            missedTopics.append(currentCard.topic)
            missedCardIDs.append(currentCard.id)
        }

        selectedOptionIDs.removeAll()

        if currentIndex + 1 >= deck.cards.count {
            finish(reason: .completed)
        } else {
            currentIndex += 1
        }
    }

    func requestExit() {
        showExitConfirmation = true
    }

    func dismissExitConfirmation() {
        showExitConfirmation = false
    }

    func confirmExit() {
        showExitConfirmation = false
        finish(reason: .exitedEarly)
    }

    func stopServices() {
        timerService.stop()
        noiseService.stop()
    }

    private func startSession() {
        startedAt = Date()
        if stressSoundEnabled {
            noiseService.start()
        }
        timerService.start { [weak self] in
            self?.tick()
        }
    }

    private func tick() {
        remainingSeconds -= 1
        if remainingSeconds <= 0 {
            remainingSeconds = 0
            finish(reason: .timedOut)
        }
    }

    private func finish(reason: SessionCompletionReason) {
        guard !isFinished else { return }
        isFinished = true

        timerService.stop()
        noiseService.stop()

        let unanswered = Array(deck.cards.dropFirst(answeredQuestions))
        let allMissedTopics = missedTopics + unanswered.map(\.topic)
        let allMissedCardIDs = missedCardIDs + unanswered.map(\.id)
        let summary = SessionSummary(
            deck: deck,
            startedAt: startedAt,
            completedAt: Date(),
            elapsedSeconds: totalDuration - remainingSeconds,
            answeredQuestions: answeredQuestions,
            correctAnswers: correctAnswers,
            totalQuestions: deck.cards.count,
            missedTopics: allMissedTopics,
            missedCardIDs: allMissedCardIDs,
            completionReason: reason
        )
        onComplete(summary)
    }

    private static func format(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
