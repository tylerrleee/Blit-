import Foundation

struct ShareLink: Codable, Identifiable, Sendable, Hashable {
    let id: UUID
    let receiptId: UUID
    let code: String
    let urlSlug: String
    let createdAt: Date
    let expiresAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case receiptId = "receipt_id"
        case code
        case urlSlug = "url_slug"
        case createdAt = "created_at"
        case expiresAt = "expires_at"
    }
}
