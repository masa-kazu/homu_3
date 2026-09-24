import Foundation

struct ExamSet: Codable, Hashable, Identifiable, Sendable {
    let id: String
    let year: Int
    let session: Int
    let displayName: String
    let questions: [Question]
}

struct Question: Codable, Hashable, Identifiable, Sendable {
    let id: String
    let number: Int
    let text: String
    let choices: [String]
    let correctAnswerIndex: Int
    let explanation: String
}

enum QuestionDataError: LocalizedError, Equatable {
    case fileNotFound, unreadable, emptyCatalog
    case emptyQuestionSet(String), duplicateID(String), invalidChoiceCount(String), invalidCorrectAnswer(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound: "問題データが見つかりません。"
        case .unreadable: "問題データを読み込めませんでした。"
        case .emptyCatalog: "問題セットが登録されていません。"
        case .emptyQuestionSet(let id): "問題セット「\(id)」に問題がありません。"
        case .duplicateID(let id): "問題ID「\(id)」が重複しています。"
        case .invalidChoiceCount(let id): "問題「\(id)」の選択肢は5件必要です。"
        case .invalidCorrectAnswer(let id): "問題「\(id)」の正解番号が不正です。"
        }
    }
}

enum QuestionRepository {
    static func load(from bundle: Bundle = .main) throws -> [ExamSet] {
        guard let url = bundle.url(forResource: "questions", withExtension: "json") else { throw QuestionDataError.fileNotFound }
        guard let data = try? Data(contentsOf: url), let sets = try? JSONDecoder().decode([ExamSet].self, from: data) else { throw QuestionDataError.unreadable }
        try validate(sets)
        return sets.sorted { ($0.year, $0.session) > ($1.year, $1.session) }
    }

    static func validate(_ sets: [ExamSet]) throws {
        guard !sets.isEmpty else { throw QuestionDataError.emptyCatalog }
        var ids = Set<String>()
        for set in sets {
            guard !set.questions.isEmpty else { throw QuestionDataError.emptyQuestionSet(set.id) }
            for question in set.questions {
                guard ids.insert(question.id).inserted else { throw QuestionDataError.duplicateID(question.id) }
                guard question.choices.count == 5 else { throw QuestionDataError.invalidChoiceCount(question.id) }
                guard question.choices.indices.contains(question.correctAnswerIndex) else { throw QuestionDataError.invalidCorrectAnswer(question.id) }
            }
        }
    }
}

