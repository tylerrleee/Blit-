import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @Environment(ServiceContainer.self) private var services
    @State private var router = AppRouter()
    @State private var showCameraActionSheet = false
    @State private var showSettings = false
    @State private var dashboardViewModel: DashboardViewModel?

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch router.selectedTab {
                case .home:
                    homeTab
                case .friends:
                    friendsTab
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom tab bar
            customTabBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $showSettings) {
            if let user = appState.currentUser {
                NavigationStack {
                    SettingsView(user: user)
                }
            }
        }
        .confirmationDialog("Add Receipt", isPresented: $showCameraActionSheet) {
            Button("Scan Receipt") {
                // Placeholder for Phase 4: camera scan
            }
            Button("Photo Library") {
                // Placeholder for Phase 4: photo picker
            }
            Button("Cancel", role: .cancel) {}
        }
        .task {
            if let user = appState.currentUser, dashboardViewModel == nil {
                dashboardViewModel = DashboardViewModel(
                    databaseService: services.database,
                    currentUser: user
                )
            }
        }
        .environment(router)
    }

    // MARK: - Home Tab

    private var homeTab: some View {
        NavigationStack(path: $router.homePath) {
            Group {
                if let dashboardViewModel {
                    DashboardView(
                        viewModel: dashboardViewModel,
                        onScanReceipt: { showCameraActionSheet = true },
                        onPhotoLibrary: {
                            // Placeholder for Phase 4
                        },
                        onSeeAllHistory: {
                            router.navigate(to: .historyList)
                        },
                        onSelectReceipt: { receipt in
                            router.navigate(to: .activeSplit(receipt))
                        },
                        onAvatarTap: {
                            showSettings = true
                        }
                    )
                } else {
                    ProgressView()
                }
            }
            .navigationDestination(for: Route.self) { route in
                routeDestination(for: route)
            }
        }
    }

    // MARK: - Friends Tab

    private var friendsTab: some View {
        NavigationStack(path: $router.friendsPath) {
            FriendsView()
                .navigationDestination(for: Route.self) { route in
                    routeDestination(for: route)
                }
        }
    }

    // MARK: - Route Destinations

    @ViewBuilder
    private func routeDestination(for route: Route) -> some View {
        switch route {
        case .historyList:
            HistoryListView()
        case .activeSplit(let receipt):
            // Phase 5: replace with ActiveSplitView(receipt: receipt)
            Text("Active Split: \(receipt.restaurant)")
                .navigationTitle("Split Details")
        case .settings:
            if let user = appState.currentUser {
                SettingsView(user: user)
            }
        }
    }

    // MARK: - Custom Tab Bar

    private var customTabBar: some View {
        HStack {
            // Home tab
            tabButton(for: .home)

            Spacer()

            // Center FAB (Camera)
            centerFAB

            Spacer()

            // Friends tab
            tabButton(for: .friends)
        }
        .padding(.horizontal, BlitSpacing.xlarge)
        .padding(.top, BlitSpacing.medium)
        .padding(.bottom, BlitSpacing.small)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 8, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabButton(for tab: TabRoute) -> some View {
        Button {
            if router.selectedTab == tab {
                // Pop to root if already on this tab
                router.popToRoot()
            } else {
                router.selectedTab = tab
            }
        } label: {
            VStack(spacing: BlitSpacing.xxsmall) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 22))
                Text(tab.title)
                    .font(BlitFont.caption)
            }
            .foregroundStyle(
                router.selectedTab == tab ? Color.blitDark : Color.blitDark.opacity(0.4)
            )
        }
    }

    private var centerFAB: some View {
        Button {
            showCameraActionSheet = true
        } label: {
            Image(systemName: "camera.fill")
                .font(.system(size: 22))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.blitDark, in: Circle())
                .shadow(color: Color.blitDark.opacity(0.3), radius: 8, y: 4)
        }
        .offset(y: -12)
    }
}
