import Foundation

enum ReceiptStatus: String, Codable, Sendable, Hashable {
    case draft
    case active
    case settling
    case closed
}

struct Receipt: Codable, Identifiable, Sendable, Hashable {
    let id: UUID
    let hostId: UUID
    var restaurant: String
    var subtotal: Decimal
    var tax: Decimal
    var tip: Decimal
    var status: ReceiptStatus
    var imageURL: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case hostId = "host_id"
        case restaurant
        case subtotal
        case tax
        case tip
        case status
        case imageURL = "image_url"
        case createdAt = "created_at"
    }
}
