import Foundation

struct RegexReceiptParser: ReceiptParser, Sendable {

    // Regex literal is a value type — safe to share across isolation domains.
    // nonisolated(unsafe) is required because Swift 6 doesn't yet recognize
    // Regex as Sendable, but the literal contains no mutable state.
    private static nonisolated(unsafe) let pricePattern = /\$?\s*(\d{1,4}\.\d{2})/
    private static let subtotalKeywords: Set<String> = ["subtotal", "sub total", "sub-total"]
    private static let taxKeywords: Set<String> = ["tax", "sales tax", "hst", "gst", "vat"]
    private static let tipKeywords: Set<String> = ["tip", "gratuity", "service charge"]
    private static let totalKeywords: Set<String> = ["total", "amount due", "balance due", "grand total"]
    private static let filterKeywords: Set<String> = [
        "visa", "mastercard", "amex", "debit", "credit", "cash",
        "thank you", "thanks", "come again",
        "tel:", "phone:", "fax:",
        "www.", "http", ".com",
        "date:", "time:", "server:", "table:",
        "change", "payment",
    ]

    func parse(textBlocks: [OCRTextBlock]) async throws -> ParsedReceipt {
        guard !textBlocks.isEmpty else {
            return ParsedReceipt(items: [], subtotal: nil, tax: nil, tip: nil, restaurantName: nil, confidence: 0)
        }

        // Sort by Y position descending (top of receipt first in normalized coords)
        let sorted = textBlocks.sorted { $0.boundingBox.origin.y > $1.boundingBox.origin.y }

        var items: [ParsedLineItem] = []
        var subtotal: Decimal?
        var tax: Decimal?
        var tip: Decimal?
        var restaurantName: String?
        var totalConfidence: Float = 0
        var blockCount: Float = 0

        for (index, block) in sorted.enumerated() {
            let text = block.text.trimmingCharacters(in: .whitespacesAndNewlines)
            let lower = text.lowercased()
            totalConfidence += block.confidence
            blockCount += 1

            // First non-price block is likely the restaurant name
            if index == 0, restaurantName == nil, !containsPrice(text) {
                restaurantName = text
                continue
            }

            // Skip filtered lines
            if isFilteredLine(lower) { continue }

            // Check for special lines: subtotal, tax, tip, total
            if let price = extractPrice(text) {
                if matchesKeyword(lower, keywords: Self.subtotalKeywords) {
                    subtotal = price
                } else if matchesKeyword(lower, keywords: Self.taxKeywords) {
                    tax = price
                } else if matchesKeyword(lower, keywords: Self.tipKeywords) {
                    tip = price
                } else if matchesKeyword(lower, keywords: Self.totalKeywords) {
                    // total line — skip, don't add as item
                } else {
                    // It's an item line
                    let name = extractItemName(text)
                    if !name.isEmpty {
                        items.append(ParsedLineItem(
                            name: name,
                            price: price,
                            confidence: block.confidence
                        ))
                    }
                }
            }
        }

        let avgConfidence = blockCount > 0 ? totalConfidence / blockCount : 0

        return ParsedReceipt(
            items: items,
            subtotal: subtotal,
            tax: tax,
            tip: tip,
            restaurantName: restaurantName,
            confidence: avgConfidence
        )
    }

    // MARK: - Helpers

    private func containsPrice(_ text: String) -> Bool {
        text.contains(Self.pricePattern)
    }

    private func extractPrice(_ text: String) -> Decimal? {
        guard let match = text.firstMatch(of: Self.pricePattern) else { return nil }
        return Decimal(string: String(match.1))
    }

    private func extractItemName(_ text: String) -> String {
        var name = text
        // Remove price portion
        if let range = name.firstMatch(of: Self.pricePattern)?.range {
            name = String(name[name.startIndex..<range.lowerBound])
        }
        // Clean up
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        name = name.trimmingCharacters(in: CharacterSet(charactersIn: ".-:*"))
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return name
    }

    private func matchesKeyword(_ lower: String, keywords: Set<String>) -> Bool {
        keywords.contains { lower.contains($0) }
    }

    private func isFilteredLine(_ lower: String) -> Bool {
        Self.filterKeywords.contains { lower.contains($0) }
    }
}
