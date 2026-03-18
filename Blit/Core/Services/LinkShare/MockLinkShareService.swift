import Foundation

// @unchecked Sendable is safe: no stored properties, no mutable state.
// All methods construct fresh values and return them.
final class MockLinkShareService: LinkShareService, @unchecked Sendable {
    func generateLink(for receiptId: UUID) async throws -> ShareLink {
        ShareLink(
            id: UUID(),
            receiptId: receiptId,
            code: "ABC123",
            urlSlug: "abc123",
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(86400)
        )
    }

    func validateInviteCode(_ code: String) async throws -> ShareLink {
        ShareLink(
            id: UUID(),
            receiptId: UUID(),
            code: code,
            urlSlug: code.lowercased(),
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(86400)
        )
    }
}
