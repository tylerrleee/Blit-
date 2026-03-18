import Foundation

struct ParticipantShare: Sendable, Hashable, Identifiable {
    let participantId: UUID
    let subtotal: Decimal
    let taxShare: Decimal
    let tipShare: Decimal
    let total: Decimal
    let items: [LineItem]

    var id: UUID { participantId }
}
