import Foundation

struct QuestionDeck: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let subjectLabel: String
    let gradientColors: [String]
    let cards: [QuestionCard]

    init(
        id: String,
        title: String,
        subtitle: String,
        subjectLabel: String,
        gradientColors: [String],
        cards: [QuestionCard]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.subjectLabel = subjectLabel
        self.gradientColors = gradientColors
        self.cards = cards
    }
}
