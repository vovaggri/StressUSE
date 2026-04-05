import Foundation

struct QuestionCard: Identifiable, Codable, Hashable {
    let id: String
    let subject: String
    let topic: String
    let prompt: String
    let hint: String
    let options: [AnswerOption]
    let correctOptionIDs: Set<String>

    init(
        id: String,
        subject: String,
        topic: String,
        prompt: String,
        hint: String,
        options: [AnswerOption],
        correctOptionIDs: Set<String>
    ) {
        self.id = id
        self.subject = subject
        self.topic = topic
        self.prompt = prompt
        self.hint = hint
        self.options = options
        self.correctOptionIDs = correctOptionIDs
    }
}
