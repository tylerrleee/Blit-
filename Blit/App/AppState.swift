import Foundation
import Observation

@MainActor @Observable final class AppState {
    var currentUser: User?
    var isLoading = true
    var isAuthenticated: Bool { currentUser != nil }

    private let authService: any AuthService

    // nonisolated(unsafe) allows deinit (which is nonisolated) to cancel the task.
    // Task.cancel() is itself concurrency-safe. @ObservationIgnored excludes from Observable tracking.
    @ObservationIgnored
    private nonisolated(unsafe) var authListenerTask: Task<Void, Never>?

    init(authService: any AuthService) {
        self.authService = authService
    }

    deinit {
        authListenerTask?.cancel()
    }

    func restoreSession() async {
        isLoading = true
        let user = try? await authService.restoreSession()
        currentUser = user
        isLoading = false
    }

    func signOut() async {
        do {
            try await authService.signOut()
            currentUser = nil
        } catch {
            currentUser = nil
        }
    }

    /// Start listening to auth state changes. Call after `restoreSession()` completes
    /// to avoid a logical race between session restoration and stream events.
    func startListening() {
        // Captures self strongly for the lifetime of the stream after guard let.
        // Task is cancelled in deinit via authListenerTask?.cancel().
        authListenerTask = Task { [weak self] in
            guard let self else { return }
            for await state in self.authService.authStateChanges {
                switch state {
                case .signedIn(let user):
                    self.currentUser = user
                case .signedOut:
                    self.currentUser = nil
                }
            }
        }
    }

    func cancelListening() {
        authListenerTask?.cancel()
        authListenerTask = nil
    }
}
