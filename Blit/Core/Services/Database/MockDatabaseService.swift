import Foundation

final class MockDatabaseService: DatabaseService, @unchecked Sendable {
    var receipts: [Receipt] = []
    var lineItems: [LineItem] = []
    var participants: [Participant] = []

    func createReceipt(_ receipt: Receipt) async throws -> Receipt {
        receipts.append(receipt)
        return receipt
    }

    func createLineItems(_ items: [LineItem], receiptId: UUID) async throws -> [LineItem] {
        lineItems.append(contentsOf: items)
        return items
    }

    func addParticipant(_ participant: Participant) async throws -> Participant {
        participants.append(participant)
        return participant
    }

    func fetchReceipt(id: UUID) async throws -> Receipt {
        guard let receipt = receipts.first(where: { $0.id == id }) else {
            throw AppError.notFound(resource: "Receipt")
        }
        return receipt
    }

    func fetchLineItems(receiptId: UUID) async throws -> [LineItem] {
        lineItems.filter { $0.receiptId == receiptId }
    }

    func fetchParticipants(receiptId: UUID) async throws -> [Participant] {
        participants.filter { $0.receiptId == receiptId }
    }

    func updateLineItem(_ item: LineItem) async throws {
        if let index = lineItems.firstIndex(where: { $0.id == item.id }) {
            lineItems[index] = item
        }
    }

    func fetchUserReceipts(userId: UUID) async throws -> [Receipt] {
        receipts.filter { $0.hostId == userId }
    }

    func uploadReceiptImage(_ imageData: Data, receiptId: UUID) async throws -> URL {
        URL(string: "https://example.com/receipts/\(receiptId).jpg")!
    }
}
