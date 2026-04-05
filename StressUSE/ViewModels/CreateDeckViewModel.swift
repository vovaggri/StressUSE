import Foundation
import Observation

@Observable
@MainActor
final class CreateDeckViewModel {
    struct DraftOption: Identifiable, Hashable {
        let id: UUID
        var text: String
        var isCorrect: Bool

        init(id: UUID = UUID(), text: String = "", isCorrect: Bool = false) {
            self.id = id
            self.text = text
            self.isCorrect = isCorrect
        }
    }

    struct DraftQuestion: Identifiable, Hashable {
        let id: UUID
        var topic: String
        var prompt: String
        var hint: String
        var options: [DraftOption]

        init(
            id: UUID = UUID(),
            topic: String = "",
            prompt: String = "",
            hint: String = "Можно выбрать несколько вариантов.",
            options: [DraftOption] = [
                DraftOption(),
                DraftOption(),
                DraftOption(),
                DraftOption()
            ]
        ) {
            self.id = id
            self.topic = topic
            self.prompt = prompt
            self.hint = hint
            self.options = options
        }
    }

    var title = ""
    var subtitle = ""
    var selectedSubjectID = ExamSubjectCatalog.defaultSubject.id
    var questions: [DraftQuestion] = [DraftQuestion()]
    var errorMessage: String?

    var subjects: [ExamSubject] {
        ExamSubjectCatalog.all
    }

    var selectedSubject: ExamSubject {
        ExamSubjectCatalog.subject(withID: selectedSubjectID)
    }

    func addQuestion() {
        questions.append(DraftQuestion())
    }

    func removeQuestion(id: UUID) {
        guard questions.count > 1 else { return }
        questions.removeAll { $0.id == id }
    }

    func addOption(to questionID: UUID) {
        guard let index = questions.firstIndex(where: { $0.id == questionID }),
              questions[index].options.count < 6 else { return }
        questions[index].options.append(DraftOption())
    }

    func removeOption(questionID: UUID, optionID: UUID) {
        guard let questionIndex = questions.firstIndex(where: { $0.id == questionID }) else { return }
        guard questions[questionIndex].options.count > 2 else { return }
        questions[questionIndex].options.removeAll { $0.id == optionID }
    }

    func buildDeck() -> QuestionDeck? {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            errorMessage = "Добавь название набора."
            return nil
        }

        let builtCards = questions.compactMap { question -> QuestionCard? in
            let topic = question.topic.trimmingCharacters(in: .whitespacesAndNewlines)
            let prompt = question.prompt.trimmingCharacters(in: .whitespacesAndNewlines)
            let hint = question.hint.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !topic.isEmpty, !prompt.isEmpty else { return nil }

            let filledOptions = question.options
                .map { option in
                    DraftOption(id: option.id, text: option.text.trimmingCharacters(in: .whitespacesAndNewlines), isCorrect: option.isCorrect)
                }
                .filter { !$0.text.isEmpty }

            guard filledOptions.count >= 2 else { return nil }

            let correctOptionIDs = Set(
                filledOptions.enumerated().compactMap { index, option in
                    option.isCorrect ? "\(index + 1)" : nil
                }
            )

            guard !correctOptionIDs.isEmpty else { return nil }

            return QuestionCard(
                id: "custom-card-\(UUID().uuidString)",
                subject: selectedSubject.name,
                topic: topic,
                prompt: prompt,
                hint: hint.isEmpty ? "Можно выбрать несколько вариантов." : hint,
                options: filledOptions.enumerated().map { index, option in
                    AnswerOption(id: "\(index + 1)", text: option.text)
                },
                correctOptionIDs: correctOptionIDs
            )
        }

        guard builtCards.count == questions.count else {
            errorMessage = "Проверь вопросы: у каждого должны быть тема, формулировка, минимум 2 варианта и хотя бы 1 правильный ответ."
            return nil
        }

        let trimmedSubtitle = subtitle.trimmingCharacters(in: .whitespacesAndNewlines)
        errorMessage = nil

        return QuestionDeck(
            id: "custom-deck-\(UUID().uuidString)",
            title: trimmedTitle,
            subtitle: trimmedSubtitle.isEmpty ? "Пользовательский набор по предмету \(selectedSubject.name)." : trimmedSubtitle,
            subjectLabel: selectedSubject.subjectLabel,
            gradientColors: selectedSubject.gradientColors,
            cards: builtCards
        )
    }
}
