import SwiftUI

struct ResultView: View {
    let title: String
    let total: Int
    let correctCount: Int
    let restart: () -> Void
    private var percentage: Int { total == 0 ? 0 : Int((Double(correctCount) / Double(total) * 100).rounded()) }
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.seal.fill").font(.system(size: 64)).foregroundStyle(.indigo)
            VStack(spacing: 8) { Text("学習完了").font(.largeTitle.bold()); Text(title).foregroundStyle(.secondary) }
            VStack(spacing: 8) {
                Text("\(percentage)%").font(.system(size: 52, weight: .bold, design: .rounded))
                Text("\(total)問中 \(correctCount)問正解・誤答 \(total - correctCount)問").foregroundStyle(.secondary)
            }
            .padding(24).frame(maxWidth: .infinity).background(.indigo.opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
            Button("もう一度解く", action: restart).buttonStyle(.borderedProminent).controlSize(.large)
        }
        .padding().frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(.systemGroupedBackground))
    }
}

