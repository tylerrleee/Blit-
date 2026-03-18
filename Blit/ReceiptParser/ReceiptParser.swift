import Foundation

protocol ReceiptParser: Sendable {
    func parse(textBlocks: [OCRTextBlock]) throws -> ParsedReceipt
}
