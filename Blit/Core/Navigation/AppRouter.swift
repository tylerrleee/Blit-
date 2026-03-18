import SwiftUI

@MainActor @Observable final class AppRouter {
    var selectedTab: TabRoute = .home
    var homePath = NavigationPath()
    var friendsPath = NavigationPath()

    func navigate(to route: Route) {
        switch selectedTab {
        case .home:
            homePath.append(route)
        case .friends:
            friendsPath.append(route)
        }
    }

    func popToRoot() {
        switch selectedTab {
        case .home:
            homePath = NavigationPath()
        case .friends:
            friendsPath = NavigationPath()
        }
    }
}
