import Foundation

enum RealtimeEvent: Sendable {
    case lineItemUpdated(LineItem)
    case participantUpdated(Participant)
    case participantAdded(Participant)
    case receiptUpdated(Receipt)
}

protocol RealtimeService: Sendable {
    func subscribeToReceipt(id: UUID) -> AsyncStream<RealtimeEvent>
    func unsubscribe(receiptId: UUID) async
}
