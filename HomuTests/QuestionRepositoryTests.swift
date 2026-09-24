import XCTest
@testable import Homu

final class QuestionRepositoryTests: XCTestCase {
    private var valid: Question { Question(id: "q1", number: 1, text: "問題", choices: ["A","B","C","D","E"], correctAnswerIndex: 0, explanation: "解説") }
    private func set(_ questions: [Question]) -> ExamSet { ExamSet(id: "set", year: 2026, session: 1, displayName: "第1回", questions: questions) }
    func testValidCatalog() { XCTAssertNoThrow(try QuestionRepository.validate([set([valid])])) }
    func testChoiceCountMustBeFive() {
        let q = Question(id: "q1", number: 1, text: "問題", choices: ["A"], correctAnswerIndex: 0, explanation: "解説")
        XCTAssertThrowsError(try QuestionRepository.validate([set([q])])) { XCTAssertEqual($0 as? QuestionDataError, .invalidChoiceCount("q1")) }
    }
    func testAnswerMustBeInRange() {
        let q = Question(id: "q1", number: 1, text: "問題", choices: ["A","B","C","D","E"], correctAnswerIndex: 5, explanation: "解説")
        XCTAssertThrowsError(try QuestionRepository.validate([set([q])])) { XCTAssertEqual($0 as? QuestionDataError, .invalidCorrectAnswer("q1")) }
    }
    func testIDsMustBeUnique() {
        let second = ExamSet(id: "other", year: 2025, session: 2, displayName: "第2回", questions: [valid])
        XCTAssertThrowsError(try QuestionRepository.validate([set([valid]), second])) { XCTAssertEqual($0 as? QuestionDataError, .duplicateID("q1")) }
    }
}
