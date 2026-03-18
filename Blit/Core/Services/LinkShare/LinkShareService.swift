import Foundation

protocol LinkShareService: Sendable {
    func generateLink(for receiptId: UUID) async throws -> ShareLink
    func validateInviteCode(_ code: String) async throws -> ShareLink
}
