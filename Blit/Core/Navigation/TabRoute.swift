import Foundation

enum TabRoute: Int, CaseIterable, Sendable {
    case home = 0
    case friends = 1

    var title: String {
        switch self {
        case .home: "Home"
        case .friends: "Friends"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "house.fill"
        case .friends: "person.2.fill"
        }
    }
}
