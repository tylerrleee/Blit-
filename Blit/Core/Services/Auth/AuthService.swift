import Foundation

enum AuthState: Sendable {
    case signedIn(User)
    case signedOut
}

protocol AuthService: Sendable {
    func signInWithGoogle() async throws
    func signOut() async throws
    func restoreSession() async throws -> User?
    var authStateChanges: AsyncStream<AuthState> { get }

    // TODO: Email auth deferred post-MVP
    // func signInWithEmail(email: String, password: String) async throws
    // func signUpWithEmail(email: String, password: String) async throws
}
