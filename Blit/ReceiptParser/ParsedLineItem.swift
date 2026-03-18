import Foundation

struct ParsedLineItem: Sendable, Hashable {
    let name: String
    let price: Decimal
    let confidence: Float
}
