import Foundation

protocol PersistenceServicing {
    func loadHistory() -> [SessionRecord]
    func saveHistory(_ history: [SessionRecord])
    func loadWeakTopicStats() -> [String: Int]
    func saveWeakTopicStats(_ stats: [String: Int])
    func loadCustomDecks() -> [QuestionDeck]
    func saveCustomDecks(_ decks: [QuestionDeck])
}

struct PersistenceService: PersistenceServicing {
    private let defaults = UserDefaults.standard
    private let historyKey = "stressuse.history"
    private let weakTopicsKey = "stressuse.weaktopics"
    private let customDecksKey = "stressuse.customdecks"

    func loadHistory() -> [SessionRecord] {
        decode([SessionRecord].self, forKey: historyKey) ?? []
    }

    func saveHistory(_ history: [SessionRecord]) {
        encode(history, forKey: historyKey)
    }

    func loadWeakTopicStats() -> [String: Int] {
        decode([String: Int].self, forKey: weakTopicsKey) ?? [:]
    }

    func saveWeakTopicStats(_ stats: [String: Int]) {
        encode(stats, forKey: weakTopicsKey)
    }

    func loadCustomDecks() -> [QuestionDeck] {
        decode([QuestionDeck].self, forKey: customDecksKey) ?? []
    }

    func saveCustomDecks(_ decks: [QuestionDeck]) {
        encode(decks, forKey: customDecksKey)
    }

    private func encode<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private func decode<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
