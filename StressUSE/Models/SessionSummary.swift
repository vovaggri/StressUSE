import Foundation

struct SessionSummary {
    let deck: QuestionDeck
    let startedAt: Date
    let completedAt: Date
    let elapsedSeconds: Int
    let answeredQuestions: Int
    let correctAnswers: Int
    let totalQuestions: Int
    let missedTopics: [String]
    let missedCardIDs: [String]
    let completionReason: SessionCompletionReason
}
