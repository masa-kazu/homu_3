import SwiftData
import SwiftUI

struct QuizView: View {
    enum Mode {
        case exam(ExamSet), review(String, [Question])
        var title: String { switch self { case .exam(let x): x.displayName; case .review(let x, _): x } }
        var questions: [Question] { switch self { case .exam(let x): x.questions; case .review(_, let x): x } }
        var examID: String? { if case .exam(let x) = self { x.id } else { nil } }
    }
    @Environment(\.modelContext) private var context
    @Query private var records: [LearningRecord]
    @Query private var progresses: [ExamProgress]
    @Query private var bookmarks: [Bookmark]
    let mode: Mode
    @State private var index = 0
    @State private var selection: Int?
    @State private var submitted = false
    @State private var correctIDs = Set<String>()
    @State private var showingResult = false
    @State private var initialized = false

    init(examSet: ExamSet) { mode = .exam(examSet) }
    init(reviewTitle: String, questions: [Question]) { mode = .review(reviewTitle, questions) }
    private var question: Question { mode.questions[index] }
    private var bookmarked: Bool { bookmarks.contains { $0.questionID == question.id } }

    var body: some View {
        Group {
            if showingResult { ResultView(title: mode.title, total: mode.questions.count, correctCount: correctIDs.count, restart: restart) }
            else { questionView }
        }
        .navigationTitle(mode.title).navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: initialize)
    }

    private var questionView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("問題 \(index + 1) / \(mode.questions.count)").font(.subheadline.bold())
                    Spacer(); ProgressView(value: Double(index + 1), total: Double(mode.questions.count)).frame(width: 110)
                }
                Text(question.text).font(.title3.bold()).accessibilityAddTraits(.isHeader)
                VStack(spacing: 12) {
                    ForEach(question.choices.indices, id: \.self) { choice in
                        ChoiceButton(index: choice, text: question.choices[choice], selected: selection,
                                     correct: submitted ? question.correctAnswerIndex : nil, submitted: submitted) {
                            if !submitted { selection = choice }
                        }
                    }
                }
                if submitted {
                    FeedbackCard(isCorrect: selection == question.correctAnswerIndex,
                                 correctChoice: question.choices[question.correctAnswerIndex], explanation: question.explanation)
                    Button(action: toggleBookmark) {
                        Label(bookmarked ? "お気に入りから外す" : "お気に入りに追加", systemImage: bookmarked ? "bookmark.fill" : "bookmark")
                            .frame(maxWidth: .infinity)
                    }.buttonStyle(.bordered).accessibilityIdentifier("bookmarkButton")
                }
                Button(action: primaryAction) {
                    Text(submitted ? (index == mode.questions.count - 1 ? "結果を見る" : "次の問題") : "回答する")
                        .bold().frame(maxWidth: .infinity).padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent).disabled(selection == nil).accessibilityIdentifier("primaryQuizButton")
            }.padding()
        }.background(Color(.systemGroupedBackground))
    }

    private func initialize() {
        guard !initialized else { return }; initialized = true
        guard let id = mode.examID, let progress = progresses.first(where: { $0.examSetID == id }) else { return }
        if progress.isCompleted {
            progress.reset()
            try? context.save()
        } else {
            index = min(progress.currentIndex, mode.questions.count - 1)
            correctIDs = progress.correctIDs
        }
    }
    private func primaryAction() {
        if !submitted { submit() }
        else if index == mode.questions.count - 1 { finish() }
        else { index += 1; selection = nil; submitted = false; progress()?.currentIndex = index; try? context.save() }
    }
    private func submit() {
        guard let selection else { return }
        let correct = selection == question.correctAnswerIndex
        if correct { correctIDs.insert(question.id) } else { correctIDs.remove(question.id) }
        if let record = records.first(where: { $0.questionID == question.id }) {
            record.selectedAnswerIndex = selection; record.latestWasCorrect = correct; record.answeredAt = .now; record.answerCount += 1
        } else { context.insert(LearningRecord(questionID: question.id, selectedAnswerIndex: selection, latestWasCorrect: correct)) }
        if let progress = progress() { var ids = progress.answeredIDs; ids.insert(question.id); progress.answeredIDs = ids; progress.correctIDs = correctIDs }
        submitted = true; try? context.save()
    }
    private func finish() { if let progress = progress() { progress.currentIndex = index; progress.correctIDs = correctIDs; progress.isCompleted = true }; try? context.save(); showingResult = true }
    private func restart() { index = 0; selection = nil; submitted = false; correctIDs = []; showingResult = false; progress()?.reset(); try? context.save() }
    private func progress() -> ExamProgress? {
        guard let id = mode.examID else { return nil }
        if let value = progresses.first(where: { $0.examSetID == id }) { return value }
        let value = ExamProgress(examSetID: id); context.insert(value); return value
    }
    private func toggleBookmark() {
        if let value = bookmarks.first(where: { $0.questionID == question.id }) { context.delete(value) }
        else { context.insert(Bookmark(questionID: question.id)) }
        try? context.save()
    }
}

private struct ChoiceButton: View {
    let index: Int, text: String
    let selected: Int?, correct: Int?
    let submitted: Bool
    let action: () -> Void
    private var color: Color {
        if submitted && index == correct { .green } else if submitted && index == selected { .red } else if index == selected { .indigo } else { .secondary }
    }
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Text(String(UnicodeScalar(65 + index)!)).font(.headline).frame(width: 32, height: 32).background(color.opacity(0.15), in: Circle())
                Text(text).frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(.primary).padding().background(.background, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(color, lineWidth: index == selected || index == correct ? 2 : 1))
        }
        .buttonStyle(.plain).disabled(submitted)
        .accessibilityLabel("選択肢\(index + 1)、\(text)").accessibilityValue(index == selected ? "選択中" : "")
    }
}

private struct FeedbackCard: View {
    let isCorrect: Bool, correctChoice: String, explanation: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(isCorrect ? "正解です" : "不正解です", systemImage: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.headline).foregroundStyle(isCorrect ? .green : .red)
            if !isCorrect { Text("正解：\(correctChoice)").font(.subheadline.bold()) }
            Text(explanation)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding()
        .background((isCorrect ? Color.green : Color.red).opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
    }
}
