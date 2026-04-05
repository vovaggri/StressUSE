import Foundation

struct DeckDetailViewModel {
    let deck: QuestionDeck
    let weakTopicStats: [String: Int]
    let recentResults: [SessionRecord]

    var cardCountText: String {
        "\(deck.cards.count) вопросов"
    }

    var stressRuleText: String {
        "20 минут, фоновый шум активен всю сессию, неотвеченные вопросы считаются ошибками."
    }

    var topWeakTopics: [String] {
        let topics = Set(deck.cards.map(\.topic))
        return topics
            .sorted { weakTopicStats[$0, default: 0] > weakTopicStats[$1, default: 0] }
            .filter { weakTopicStats[$0, default: 0] > 0 }
    }

    var averageScoreText: String {
        guard !recentResults.isEmpty else { return "Пока нет попыток" }
        let average = recentResults.map(\.scoreFraction).reduce(0, +) / Double(recentResults.count)
        return "\(Int(average * 100))% средний результат"
    }
}
