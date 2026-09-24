import Foundation
import Observation

@MainActor @Observable final class QuestionCatalog {
    enum State { case loading, loaded([ExamSet]), failed(String) }
    private(set) var state: State = .loading
    func load() async {
        do { state = .loaded(try QuestionRepository.load()) }
        catch { state = .failed(error.localizedDescription) }
    }
    var examSets: [ExamSet] { if case .loaded(let sets) = state { sets } else { [] } }
    var allQuestions: [Question] { examSets.flatMap(\.questions) }
}

