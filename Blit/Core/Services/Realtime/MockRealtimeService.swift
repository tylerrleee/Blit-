import Foundation

// @unchecked Sendable is safe: all stored properties are `let` constants of Sendable types
// (AsyncStream and AsyncStream.Continuation are both Sendable).
// No mutable state, no retain cycle — continuation captured at init time, not in closure.
final class MockRealtimeService: RealtimeService, @unchecked Sendable {
    private let continuation: AsyncStream<RealtimeEvent>.Continuation
    private let _stream: AsyncStream<RealtimeEvent>

    init() {
        var cont: AsyncStream<RealtimeEvent>.Continuation!
        _stream = AsyncStream { cont = $0 }
        continuation = cont
    }

    func subscribeToReceipt(id: UUID) -> AsyncStream<RealtimeEvent> {
        _stream
    }

    func unsubscribe(receiptId: UUID) async {
        continuation.finish()
    }

    func emit(_ event: RealtimeEvent) {
        continuation.yield(event)
    }
}
