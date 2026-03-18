import SwiftUI

struct HistoryListView: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(AppState.self) private var appState
    @State private var receipts: [Receipt] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var participantCounts: [UUID: Int] = [:]

    var body: some View {
        ZStack {
            Color.blitBackground
                .ignoresSafeArea()

            if isLoading {
                ProgressView()
            } else if receipts.isEmpty {
                emptyState
            } else {
                receiptList
            }
        }
        .navigationTitle("History")
        .task {
            await loadHistory()
        }
        .alert("Error", isPresented: .init(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { errorMessage = nil }
        } message: {
            if let msg = errorMessage {
                Text(msg)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: BlitSpacing.medium) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundStyle(Color.blitDark.opacity(0.3))

            Text("No history yet")
                .font(BlitFont.title)
                .foregroundStyle(Color.blitDark)

            Text("Your past splits will appear here")
                .font(BlitFont.callout)
                .foregroundStyle(Color.blitDark.opacity(0.6))
        }
    }

    private var receiptList: some View {
        ScrollView {
            LazyVStack(spacing: BlitSpacing.small) {
                ForEach(receipts) { receipt in
                    RecentSplitCard(
                        receipt: receipt,
                        participantCount: participantCounts[receipt.id] ?? 0
                    )
                    .padding(.horizontal, BlitSpacing.medium)
                }
            }
            .padding(.top, BlitSpacing.medium)
        }
    }

    private func loadHistory() async {
        isLoading = true
        guard let userId = appState.currentUser?.id else {
            isLoading = false
            return
        }
        do {
            receipts = try await services.database.fetchUserReceipts(userId: userId)
            await loadParticipantCounts()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func loadParticipantCounts() async {
        await withTaskGroup(of: (UUID, Int).self) { group in
            for receipt in receipts {
                group.addTask {
                    let count = (try? await services.database.fetchParticipants(receiptId: receipt.id))?.count ?? 0
                    return (receipt.id, count)
                }
            }
            for await (id, count) in group {
                participantCounts[id] = count
            }
        }
    }
}
