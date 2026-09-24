import Foundation
import SwiftData

@Model final class LearningRecord {
    @Attribute(.unique) var questionID: String
    var selectedAnswerIndex: Int
    var latestWasCorrect: Bool
    var answeredAt: Date
    var answerCount: Int
    init(questionID: String, selectedAnswerIndex: Int, latestWasCorrect: Bool) {
        self.questionID = questionID; self.selectedAnswerIndex = selectedAnswerIndex
        self.latestWasCorrect = latestWasCorrect; answeredAt = .now; answerCount = 1
    }
}

@Model final class ExamProgress {
    @Attribute(.unique) var examSetID: String
    var currentIndex: Int
    var startedAt: Date
    var isCompleted: Bool
    var answeredQuestionIDs: String
    var correctQuestionIDs: String
    init(examSetID: String) {
        self.examSetID = examSetID; currentIndex = 0; startedAt = .now; isCompleted = false
        answeredQuestionIDs = ""; correctQuestionIDs = ""
    }
    var answeredIDs: Set<String> {
        get { Set(answeredQuestionIDs.split(separator: ",").map(String.init)) }
        set { answeredQuestionIDs = newValue.sorted().joined(separator: ",") }
    }
    var correctIDs: Set<String> {
        get { Set(correctQuestionIDs.split(separator: ",").map(String.init)) }
        set { correctQuestionIDs = newValue.sorted().joined(separator: ",") }
    }
    func reset() { currentIndex = 0; startedAt = .now; isCompleted = false; answeredQuestionIDs = ""; correctQuestionIDs = "" }
}

@Model final class Bookmark {
    @Attribute(.unique) var questionID: String
    var createdAt: Date
    init(questionID: String) { self.questionID = questionID; createdAt = .now }
}

