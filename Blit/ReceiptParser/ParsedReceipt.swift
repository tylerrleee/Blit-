import Foundation

struct ParsedReceipt: Sendable, Hashable {
    let items: [ParsedLineItem]
    let subtotal: Decimal?
    let tax: Decimal?
    let tip: Decimal?
    let restaurantName: String?
    let confidence: Float
}
