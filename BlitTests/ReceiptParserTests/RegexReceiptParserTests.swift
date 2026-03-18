import Testing
import Foundation
import CoreGraphics
@testable import Blit

// MARK: - Test Helpers

private func block(_ text: String, y: CGFloat, confidence: Float = 0.95) -> OCRTextBlock {
    OCRTextBlock(text: text, confidence: confidence, boundingBox: CGRect(x: 0, y: y, width: 1, height: 0.02))
}

// MARK: - Standard Receipt Format

@Test("Parses standard restaurant receipt with items, subtotal, tax, tip")
func standardReceipt() async throws {
    let blocks: [OCRTextBlock] = [
        block("The Blue Bistro", y: 0.95),
        block("Truffle Fries $12.00", y: 0.80),
        block("Spicy Rigatoni $24.00", y: 0.75),
        block("Ribeye Steak $48.00", y: 0.70),
        block("Subtotal $84.00", y: 0.40),
        block("Tax $7.56", y: 0.35),
        block("Tip $16.80", y: 0.30),
        block("Total $108.36", y: 0.25),
    ]

    let parser = RegexReceiptParser()
    let result = try await parser.parse(textBlocks: blocks)

    #expect(result.items.count == 3)
    #expect(result.items[0].name == "Truffle Fries")
    #expect(result.items[0].price == Decimal(string: "12.00")!)
    #expect(result.items[1].name == "Spicy Rigatoni")
    #expect(result.items[1].price == Decimal(string: "24.00")!)
    #expect(result.items[2].name == "Ribeye Steak")
    #expect(result.items[2].price == Decimal(string: "48.00")!)
    #expect(result.subtotal == Decimal(string: "84.00")!)
    #expect(result.tax == Decimal(string: "7.56")!)
    #expect(result.tip == Decimal(string: "16.80")!)
}

@Test("Extracts restaurant name from first text block")
func restaurantNameExtraction() async throws {
    let blocks: [OCRTextBlock] = [
        block("Pasta Palace", y: 0.95),
        block("Margherita Pizza $18.50", y: 0.80),
        block("Subtotal $18.50", y: 0.40),
    ]

    let parser = RegexReceiptParser()
    let result = try await parser.parse(textBlocks: blocks)

    #expect(result.restaurantName == "Pasta Palace")
}

// MARK: - Receipt Without Dollar Signs

@Test("Handles prices without dollar sign prefix")
func pricesWithoutDollarSign() async throws {
    let blocks: [OCRTextBlock] = [
        block("Cafe Roma", y: 0.95),
        block("Latte 5.50", y: 0.80),
        block("Croissant 4.25", y: 0.75),
        block("Subtotal 9.75", y: 0.40),
    ]

    let parser = RegexReceiptParser()
    let result = try await parser.parse(textBlocks: blocks)

    #expect(result.items.count == 2)
    #expect(result.items[0].price == Decimal(string: "5.50")!)
    #expect(result.items[1].price == Decimal(string: "4.25")!)
}

// MARK: - Receipt With No Tax/Tip

@Test("Handles receipt with no tax or tip lines")
func noTaxOrTip() async throws {
    let blocks: [OCRTextBlock] = [
        block("Food Truck", y: 0.95),
        block("Tacos $8.00", y: 0.80),
        block("Burrito $10.00", y: 0.75),
    ]

    let parser = RegexReceiptParser()
    let result = try await parser.parse(textBlocks: blocks)

    #expect(result.items.count == 2)
    #expect(result.tax == nil)
    #expect(result.tip == nil)
}

// MARK: - Tip as Percentage

@Test("Handles tip line with percentage indicator")
func tipAsPercentage() async throws {
    let blocks: [OCRTextBlock] = [
        block("Restaurant", y: 0.95),
        block("Dinner $40.00", y: 0.80),
        block("Subtotal $40.00", y: 0.40),
        block("Tax $3.60", y: 0.35),
        block("Tip (20%) $8.00", y: 0.30),
    ]

    let parser = RegexReceiptParser()
    let result = try await parser.parse(textBlocks: blocks)

    #expect(result.tip == Decimal(string: "8.00")!)
}

// MARK: - Filters Non-Item Lines

@Test("Filters out common non-item text: payment, thank you, address")
func filtersNonItemLines() async throws {
    let blocks: [OCRTextBlock] = [
        block("Restaurant Name", y: 0.95),
        block("123 Main St, Anytown", y: 0.92),
        block("Tel: 555-1234", y: 0.90),
        block("Chicken Wings $12.00", y: 0.80),
        block("Subtotal $12.00", y: 0.40),
        block("VISA ****1234", y: 0.20),
        block("Thank you!", y: 0.15),
    ]

    let parser = RegexReceiptParser()
    let result = try await parser.parse(textBlocks: blocks)

    #expect(result.items.count == 1)
    #expect(result.items[0].name == "Chicken Wings")
}

// MARK: - Y-Position Sorting

@Test("Blocks are sorted by Y position for correct reading order")
func yPositionSorting() async throws {
    // Provide blocks in random order — parser should sort by Y descending (top-first)
    let blocks: [OCRTextBlock] = [
        block("Tax $2.00", y: 0.35),
        block("Salad $10.00", y: 0.75),
        block("Diner", y: 0.95),
        block("Soup $8.00", y: 0.80),
        block("Subtotal $18.00", y: 0.40),
    ]

    let parser = RegexReceiptParser()
    let result = try await parser.parse(textBlocks: blocks)

    // Should find Soup before Salad based on Y-sort (descending = top first)
    #expect(result.items.count == 2)
    #expect(result.items[0].name == "Soup")
    #expect(result.items[1].name == "Salad")
}

// MARK: - Edge Cases

@Test("Empty input returns empty parsed receipt")
func emptyInput() async throws {
    let parser = RegexReceiptParser()
    let result = try await parser.parse(textBlocks: [])

    #expect(result.items.isEmpty)
    #expect(result.subtotal == nil)
    #expect(result.tax == nil)
    #expect(result.tip == nil)
    #expect(result.restaurantName == nil)
}

@Test("Low-confidence blocks are included but flagged")
func lowConfidenceBlocks() async throws {
    let blocks: [OCRTextBlock] = [
        block("Restaurant", y: 0.95, confidence: 0.30),
        block("Burger $15.00", y: 0.80, confidence: 0.40),
    ]

    let parser = RegexReceiptParser()
    let result = try await parser.parse(textBlocks: blocks)

    #expect(result.items.count == 1)
    #expect(result.confidence < 0.5)
}

@Test("Handles 'Gratuity' as tip keyword")
func gratuityAsTip() async throws {
    let blocks: [OCRTextBlock] = [
        block("Fine Dining", y: 0.95),
        block("Lobster $65.00", y: 0.80),
        block("Subtotal $65.00", y: 0.40),
        block("Tax $5.85", y: 0.35),
        block("Gratuity $13.00", y: 0.30),
    ]

    let parser = RegexReceiptParser()
    let result = try await parser.parse(textBlocks: blocks)

    #expect(result.tip == Decimal(string: "13.00")!)
}
