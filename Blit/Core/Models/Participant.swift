import Foundation

enum ParticipantStatus: String, Codable, Sendable, Hashable {
    case invited
    case selecting
    case confirmed
    case settled
}

struct Participant: Codable, Identifiable, Sendable, Hashable {
    let id: UUID
    let receiptId: UUID
    var name: String
    var status: ParticipantStatus
    var userId: UUID?

    enum CodingKeys: String, CodingKey {
        case id
        case receiptId = "receipt_id"
        case name
        case status
        case userId = "user_id"
    }
}
