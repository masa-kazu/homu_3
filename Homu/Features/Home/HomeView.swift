import SwiftData
import SwiftUI

struct HomeView: View {
    let examSets: [ExamSet]
    @Query private var records: [LearningRecord]
    @Query private var progressItems: [ExamProgress]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("今日も一問ずつ積み重ねよう", systemImage: "sparkles").font(.headline)
                    Text("試験回を選ぶと、前回の続きから学習できます。").font(.subheadline).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading).padding()
                .background(.indigo.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))

                ForEach(examSets) { examSet in
                    NavigationLink { QuizView(examSet: examSet) } label: {
                        ExamSetCard(examSet: examSet, progress: progressItems.first { $0.examSetID == examSet.id }, records: records)
                    }.buttonStyle(.plain)
                }
            }.padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("法務3級")
    }
}

private struct ExamSetCard: View {
    let examSet: ExamSet
    let progress: ExamProgress?
    let records: [LearningRecord]
    private var answered: Int { examSet.questions.filter { q in records.contains { $0.questionID == q.id } }.count }
    private var correct: Int { examSet.questions.filter { q in records.first { $0.questionID == q.id }?.latestWasCorrect == true }.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(examSet.displayName).font(.title3.bold())
                    Text("全\(examSet.questions.count)問").font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer(); Image(systemName: "chevron.right").foregroundStyle(.tertiary)
            }
            ProgressView(value: Double(answered), total: Double(examSet.questions.count)).tint(.indigo)
            HStack { Label("回答 \(answered)問", systemImage: "pencil.line"); Spacer(); Label("正解 \(correct)問", systemImage: "checkmark.circle") }
                .font(.caption).foregroundStyle(.secondary)
            if let progress, !progress.isCompleted, progress.currentIndex > 0 {
                Label("\(progress.currentIndex + 1)問目から再開", systemImage: "play.fill").font(.caption.bold()).foregroundStyle(.indigo)
            }
        }
        .padding().background(.background, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }
}

