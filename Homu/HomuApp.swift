import SwiftData
import SwiftUI

@main
struct HomuApp: App {
    var body: some Scene {
        WindowGroup { RootView() }
            .modelContainer(for: [LearningRecord.self, ExamProgress.self, Bookmark.self])
    }
}

