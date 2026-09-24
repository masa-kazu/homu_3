import SwiftUI

struct RootView: View {
    @State private var catalog = QuestionCatalog()
    var body: some View {
        Group {
            switch catalog.state {
            case .loading: ProgressView("問題を読み込んでいます")
            case .failed(let message): ContentUnavailableView("問題を読み込めませんでした", systemImage: "exclamationmark.triangle", description: Text(message))
            case .loaded: AppTabsView(catalog: catalog)
            }
        }.task { await catalog.load() }
    }
}

private struct AppTabsView: View {
    let catalog: QuestionCatalog
    var body: some View {
        TabView {
            NavigationStack { HomeView(examSets: catalog.examSets) }.tabItem { Label("問題", systemImage: "book.closed") }
            NavigationStack { ReviewView(questions: catalog.allQuestions) }.tabItem { Label("復習", systemImage: "arrow.counterclockwise") }
            NavigationStack { SettingsView() }.tabItem { Label("設定", systemImage: "gearshape") }
        }.tint(.indigo)
    }
}
