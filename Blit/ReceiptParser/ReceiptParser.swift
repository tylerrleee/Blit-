import Foundation

protocol ReceiptParser: Sendable {
    func parse(textBlocks: [OCRTextBlock]) async throws -> ParsedReceipt
}
