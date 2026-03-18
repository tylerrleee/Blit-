import Foundation
import Auth

@MainActor
final class SupabaseAuthService: AuthService {
    let authStateChanges: AsyncStream<AuthState>
    private let continuation: AsyncStream<AuthState>.Continuation
    // nonisolated(unsafe) allows deinit (which is nonisolated) to cancel the task.
    // Task.cancel() is itself concurrency-safe, so this is a known-safe pattern.
    private nonisolated(unsafe) var listenerTask: Task<Void, Never>?

    init() {
        var cont: AsyncStream<AuthState>.Continuation!
        authStateChanges = AsyncStream { cont = $0 }
        continuation = cont

        listenerTask = Task { @MainActor [weak self] in
            for await (event, session) in supabase.auth.authStateChanges {
                guard let self else { return }
                switch event {
                case .signedIn:
                    if let session {
                        let user = self.mapUser(from: session.user)
                        self.continuation.yield(.signedIn(user))
                    }
                case .signedOut:
                    self.continuation.yield(.signedOut)
                default:
                    break
                }
            }
        }
    }

    deinit {
        listenerTask?.cancel()
    }

    func signInWithGoogle() async throws {
        try await supabase.auth.signInWithOAuth(provider: .google, redirectTo: SupabaseConfig.redirectURL)
    }

    func signOut() async throws {
        try await supabase.auth.signOut()
    }

    func restoreSession() async throws -> User? {
        guard let session = try? await supabase.auth.session else {
            return nil
        }
        return mapUser(from: session.user)
    }

    private func mapUser(from authUser: Auth.User) -> User {
        User(
            id: authUser.id,
            email: authUser.email ?? "",
            googleAuthId: authUser.appMetadata["provider"]?.value as? String,
            name: authUser.userMetadata["full_name"]?.value as? String ?? authUser.email ?? "User",
            avatarURL: authUser.userMetadata["avatar_url"]?.value as? String
        )
    }
}
