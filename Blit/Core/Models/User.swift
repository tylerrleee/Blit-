import Foundation

struct User: Codable, Identifiable, Sendable, Hashable {
    let id: UUID
    let email: String
    let googleAuthId: String?
    let name: String
    let avatarURL: String?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case googleAuthId = "google_auth_id"
        case name
        case avatarURL = "avatar_url"
    }
}
