import Foundation

protocol DatabaseService: Sendable {
    // Receipt creation flow
    func createReceipt(_ receipt: Receipt) async throws -> Receipt
    func createLineItems(_ items: [LineItem], receiptId: UUID) async throws -> [LineItem]
    func addParticipant(_ participant: Participant) async throws -> Participant

    // Loading active split
    func fetchReceipt(id: UUID) async throws -> Receipt
    func fetchLineItems(receiptId: UUID) async throws -> [LineItem]
    func fetchParticipants(receiptId: UUID) async throws -> [Participant]

    // Item assignment
    func updateLineItem(_ item: LineItem) async throws

    // Dashboard recent splits
    func fetchUserReceipts(userId: UUID) async throws -> [Receipt]

    // Image storage
    func uploadReceiptImage(_ imageData: Data, receiptId: UUID) async throws -> URL

    // Deferred: updateReceipt, updateParticipant, removeParticipant
}
