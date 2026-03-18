import Foundation

@MainActor
final class MockDatabaseService: DatabaseService {
    var receipts: [Receipt] = []
    var lineItems: [LineItem] = []
    var participants: [Participant] = []
    var shouldFail = false

    private func guardFailure() throws {
        if shouldFail {
            throw AppError.databaseError(message: "Mock failure")
        }
    }

    func createReceipt(_ receipt: Receipt) async throws -> Receipt {
        try guardFailure()
        receipts.append(receipt)
        return receipt
    }

    func createLineItems(_ items: [LineItem], receiptId: UUID) async throws -> [LineItem] {
        try guardFailure()
        lineItems.append(contentsOf: items)
        return items
    }

    func addParticipant(_ participant: Participant) async throws -> Participant {
        try guardFailure()
        participants.append(participant)
        return participant
    }

    func fetchReceipt(id: UUID) async throws -> Receipt {
        try guardFailure()
        guard let receipt = receipts.first(where: { $0.id == id }) else {
            throw AppError.notFound(resource: "Receipt")
        }
        return receipt
    }

    func fetchLineItems(receiptId: UUID) async throws -> [LineItem] {
        try guardFailure()
        return lineItems.filter { $0.receiptId == receiptId }
    }

    func fetchParticipants(receiptId: UUID) async throws -> [Participant] {
        try guardFailure()
        return participants.filter { $0.receiptId == receiptId }
    }

    func updateLineItem(_ item: LineItem) async throws {
        try guardFailure()
        if let index = lineItems.firstIndex(where: { $0.id == item.id }) {
            lineItems[index] = item
        }
    }

    func fetchUserReceipts(userId: UUID) async throws -> [Receipt] {
        try guardFailure()
        return receipts.filter { $0.hostId == userId }
    }

    func uploadReceiptImage(_ imageData: Data, receiptId: UUID) async throws -> URL {
        try guardFailure()
        return URL(string: "https://example.com/receipts/\(receiptId).jpg")!
    }
}
