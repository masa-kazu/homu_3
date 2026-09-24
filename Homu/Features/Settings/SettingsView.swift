import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var records: [LearningRecord]
    @Query private var progresses: [ExamProgress]
    @Query private var bookmarks: [Bookmark]
    @State private var confirmingReset = false
    var body: some View {
        List {
            Section("学習データ") {
                LabeledContent("回答した問題", value: "\(records.count)問")
                LabeledContent("お気に入り", value: "\(bookmarks.count)問")
                Button("学習履歴を初期化", role: .destructive) { confirmingReset = true }
            }
            Section("このアプリについて") {
                LabeledContent("対象", value: "銀行業務検定 法務3級")
                LabeledContent("バージョン", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                Text("掲載問題は学習用に独自作成したもので、公式の過去問題ではありません。本アプリの成績は、実際の試験結果や合格を保証するものではありません。")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("問題の権利") {
                Text("問題文・選択肢・解説の無断転載・再配布を禁止します。資格名および関連する名称は各権利者に帰属します。")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("設定")
        .confirmationDialog("学習履歴を初期化しますか？", isPresented: $confirmingReset, titleVisibility: .visible) {
            Button("初期化する", role: .destructive) { records.forEach(modelContext.delete); progresses.forEach(modelContext.delete); bookmarks.forEach(modelContext.delete); try? modelContext.save() }
            Button("キャンセル", role: .cancel) {}
        } message: { Text("回答履歴、途中経過、お気に入りがすべて削除されます。この操作は取り消せません。") }
    }
}
