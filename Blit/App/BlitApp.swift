import SwiftUI

@main
struct BlitApp: App {
    @State private var services = ServiceContainer(
        auth: SupabaseAuthService(),
        database: MockDatabaseService(),
        realtime: MockRealtimeService(),
        linkShare: MockLinkShareService()
    )
    @State private var appState: AppState?
    @State private var loginViewModel: LoginViewModel?

    var body: some Scene {
        WindowGroup {
            Group {
                if let appState, let loginViewModel {
                    ContentView(loginViewModel: loginViewModel)
                        .environment(appState)
                        .environment(services)
                } else {
                    ProgressView()
                }
            }
            .task {
                let state = AppState(authService: services.auth)
                let vm = LoginViewModel(authService: services.auth)
                appState = state
                loginViewModel = vm
                await state.restoreSession()
                state.startListening()
            }
            .onOpenURL { url in
                print("[AUTH] onOpenURL called with: \(url)")
                Task {
                    do {
                        let session = try await supabase.auth.session(from: url)
                        print("[AUTH] Session restored from URL: \(session.user.email ?? "no email")")
                    } catch {
                        print("[AUTH] Failed to get session from URL: \(error)")
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    @Environment(AppState.self) private var appState
    let loginViewModel: LoginViewModel

    var body: some View {
        Group {
            if appState.isLoading {
                ProgressView("Loading...")
            } else if appState.isAuthenticated {
                MainTabView()
            } else {
                LoginView(viewModel: loginViewModel)
            }
        }
    }
}
