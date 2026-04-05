import Foundation

struct ExamSubject: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let gradientColors: [String]

    init(id: String, name: String, gradientColors: [String]) {
        self.id = id
        self.name = name
        self.gradientColors = gradientColors
    }

    var subjectLabel: String {
        "ЕГЭ \(name)"
    }
}

enum ExamSubjectCatalog {
    static let all: [ExamSubject] = [
        ExamSubject(id: "russian", name: "Русский язык", gradientColors: ["#FF7A59", "#FFB457"]),
        ExamSubject(id: "math", name: "Математика", gradientColors: ["#2563EB", "#60A5FA"]),
        ExamSubject(id: "physics", name: "Физика", gradientColors: ["#0F766E", "#2DD4BF"]),
        ExamSubject(id: "chemistry", name: "Химия", gradientColors: ["#BE185D", "#FB7185"]),
        ExamSubject(id: "history", name: "История", gradientColors: ["#0E9F6E", "#95D5B2"]),
        ExamSubject(id: "social", name: "Обществознание", gradientColors: ["#1D4ED8", "#38BDF8"]),
        ExamSubject(id: "informatics", name: "Информатика", gradientColors: ["#4338CA", "#22D3EE"]),
        ExamSubject(id: "biology", name: "Биология", gradientColors: ["#15803D", "#86EFAC"]),
        ExamSubject(id: "geography", name: "География", gradientColors: ["#C2410C", "#FDBA74"]),
        ExamSubject(id: "english", name: "Английский язык", gradientColors: ["#7C3AED", "#A78BFA"]),
        ExamSubject(id: "german", name: "Немецкий язык", gradientColors: ["#475569", "#CBD5E1"]),
        ExamSubject(id: "french", name: "Французский язык", gradientColors: ["#1D4ED8", "#EF4444"]),
        ExamSubject(id: "spanish", name: "Испанский язык", gradientColors: ["#DC2626", "#F59E0B"]),
        ExamSubject(id: "chinese", name: "Китайский язык", gradientColors: ["#B91C1C", "#F97316"]),
        ExamSubject(id: "literature", name: "Литература", gradientColors: ["#7C2D12", "#F59E0B"])
    ]

    static var defaultSubject: ExamSubject {
        all[0]
    }

    static func subject(withID id: String) -> ExamSubject {
        all.first(where: { $0.id == id }) ?? defaultSubject
    }
}
