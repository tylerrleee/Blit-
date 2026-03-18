import Foundation

struct LineItem: Codable, Identifiable, Sendable, Hashable {
    let id: UUID
    let receiptId: UUID
    var name: String
    var price: Decimal
    var assignedTo: [UUID]

    enum CodingKeys: String, CodingKey {
        case id
        case receiptId = "receipt_id"
        case name
        case price
        case assignedTo = "assigned_to"
    }
}
