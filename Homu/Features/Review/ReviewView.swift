import SwiftData
import SwiftUI

struct ReviewView: View {
    enum Filter: String, CaseIterable, Identifiable { case mistakes = "間違えた問題", bookmarks = "お気に入り"; var id: Self { self } }
    let questions: [Question]
    @Query private var records: [LearningRecord]
    @Query private var bookmarks: [Bookmark]
    @State private var filter: Filter = .mistakes
    private var filtered: [Question] {
        let ids = filter == .mistakes
            ? Set(records.filter { !$0.latestWasCorrect }.map(\.questionID))
            : Set(bookmarks.map(\.questionID))
        return questions.filter { ids.contains($0.id) }
    }
    var body: some View {
        VStack(spacing: 0) {
            Picker("復習方法", selection: $filter) { ForEach(Filter.allCases) { Text($0.rawValue).tag($0) } }
                .pickerStyle(.segmented).padding()
            if filtered.isEmpty {
                ContentUnavailableView(filter == .mistakes ? "間違えた問題はありません" : "お気に入りはありません",
                    systemImage: filter == .mistakes ? "checkmark.circle" : "bookmark",
                    description: Text(filter == .mistakes ? "問題を解くと、誤答した問題がここに表示されます。" : "解説画面から気になる問題を保存できます。"))
            } else {
                List {
                    Section { NavigationLink { QuizView(reviewTitle: filter.rawValue, questions: filtered) } label: {
                        Label("\(filtered.count)問を復習する", systemImage: "play.fill").font(.headline).foregroundStyle(.indigo)
                    } }
                    Section("対象問題") { ForEach(filtered) { q in
                        VStack(alignment: .leading, spacing: 4) { Text("問題 \(q.number)").font(.caption).foregroundStyle(.secondary); Text(q.text).lineLimit(2) }
                    } }
                }.listStyle(.insetGrouped)
            }
        }.navigationTitle("復習")
    }
}

