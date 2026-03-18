import Foundation

final class MockRealtimeService: RealtimeService, @unchecked Sendable {
    private var continuation: AsyncStream<RealtimeEvent>.Continuation?

    func subscribeToReceipt(id: UUID) -> AsyncStream<RealtimeEvent> {
        AsyncStream { self.continuation = $0 }
    }

    func unsubscribe(receiptId: UUID) async {
        continuation?.finish()
        continuation = nil
    }

    func emit(_ event: RealtimeEvent) {
        continuation?.yield(event)
    }
}
