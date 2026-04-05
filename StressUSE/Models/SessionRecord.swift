import Foundation

enum SessionCompletionReason: String, Codable {
    case completed
    case timedOut
    case exitedEarly
}

struct SessionRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let deckID: String
    let deckTitle: String
    let startedAt: Date
    let completedAt: Date
    let elapsedSeconds: Int
    let answeredQuestions: Int
    let correctAnswers: Int
    let totalQuestions: Int
    let missedTopics: [String]
    let missedCardIDs: [String]
    let completionReason: SessionCompletionReason

    init(
        id: UUID = UUID(),
        deckID: String,
        deckTitle: String,
        startedAt: Date,
        completedAt: Date,
        elapsedSeconds: Int,
        answeredQuestions: Int,
        correctAnswers: Int,
        totalQuestions: Int,
        missedTopics: [String],
        missedCardIDs: [String],
        completionReason: SessionCompletionReason
    ) {
        self.id = id
        self.deckID = deckID
        self.deckTitle = deckTitle
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.elapsedSeconds = elapsedSeconds
        self.answeredQuestions = answeredQuestions
        self.correctAnswers = correctAnswers
        self.totalQuestions = totalQuestions
        self.missedTopics = missedTopics
        self.missedCardIDs = missedCardIDs
        self.completionReason = completionReason
    }

    var scoreFraction: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions)
    }
}
