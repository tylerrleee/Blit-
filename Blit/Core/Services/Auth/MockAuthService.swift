import Foundation

@MainActor
final class MockAuthService: AuthService {
    var shouldSucceed = true
    var mockUser = User(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        email: "alex@example.com",
        googleAuthId: "google-123",
        name: "Alex Rivera",
        avatarURL: nil
    )

    private let continuation: AsyncStream<AuthState>.Continuation
    let authStateChanges: AsyncStream<AuthState>

    init() {
        var cont: AsyncStream<AuthState>.Continuation!
        authStateChanges = AsyncStream { cont = $0 }
        continuation = cont
    }

    func signInWithGoogle() async throws {
        guard shouldSucceed else {
            throw AppError.authFailed(message: "Mock sign-in failed")
        }
        continuation.yield(.signedIn(mockUser))
    }

    func signOut() async throws {
        continuation.yield(.signedOut)
    }

    func restoreSession() async throws -> User? {
        shouldSucceed ? mockUser : nil
    }
}
