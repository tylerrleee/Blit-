import Foundation

enum Route: Hashable, Sendable {
    case historyList
    case activeSplit(Receipt)
    case settings
}
