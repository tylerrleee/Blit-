import Testing
import Foundation
@testable import Blit

// MARK: - LoginViewModel Tests

@Suite("LoginViewModel")
@MainActor
struct LoginViewModelTests {

    private func makeSUT(shouldSucceed: Bool = true) -> (LoginViewModel, MockAuthService) {
        let mockAuth = MockAuthService()
        mockAuth.shouldSucceed = shouldSucceed
        let vm = LoginViewModel(authService: mockAuth)
        return (vm, mockAuth)
    }

    @Test("Initial state: not loading, no error")
    func initialState() {
        let (vm, _) = makeSUT()
        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
    }

    @Test("signInWithGoogle completes with loading false")
    func signInSetsLoading() async {
        let (vm, _) = makeSUT()

        await vm.signInWithGoogle()

        #expect(vm.isLoading == false)
    }

    @Test("Successful signInWithGoogle clears error")
    func successfulSignInClearsError() async {
        let (vm, _) = makeSUT(shouldSucceed: true)
        vm.errorMessage = "Previous error"

        await vm.signInWithGoogle()

        #expect(vm.errorMessage == nil)
    }

    @Test("Failed signInWithGoogle sets error message")
    func failedSignInSetsError() async {
        let (vm, _) = makeSUT(shouldSucceed: false)

        await vm.signInWithGoogle()

        #expect(vm.isLoading == false)
        #expect(vm.errorMessage != nil)
        #expect(vm.errorMessage?.contains("Authentication failed") == true)
    }

    @Test("dismissError clears the error message")
    func dismissErrorClearsMessage() {
        let (vm, _) = makeSUT()
        vm.errorMessage = "Some error"

        vm.dismissError()

        #expect(vm.errorMessage == nil)
    }
}

// MARK: - AppState Tests

@Suite("AppState")
@MainActor
struct AppStateTests {

    @Test("Initial state: not authenticated, loading")
    func initialState() {
        let mockAuth = MockAuthService()
        let state = AppState(authService: mockAuth)

        #expect(state.isAuthenticated == false)
        #expect(state.currentUser == nil)
        #expect(state.isLoading == true)
    }

    @Test("Restore session sets user when session exists")
    func restoreSessionSetsUser() async {
        let mockAuth = MockAuthService()
        mockAuth.shouldSucceed = true
        let state = AppState(authService: mockAuth)

        await state.restoreSession()

        #expect(state.currentUser != nil)
        #expect(state.currentUser?.name == "Alex Rivera")
        #expect(state.isAuthenticated == true)
        #expect(state.isLoading == false)
    }

    @Test("Restore session with no session sets signed out")
    func restoreSessionNoSession() async {
        let mockAuth = MockAuthService()
        mockAuth.shouldSucceed = false
        let state = AppState(authService: mockAuth)

        await state.restoreSession()

        #expect(state.currentUser == nil)
        #expect(state.isAuthenticated == false)
        #expect(state.isLoading == false)
    }

    @Test("Sign out clears user")
    func signOutClearsUser() async {
        let mockAuth = MockAuthService()
        let state = AppState(authService: mockAuth)
        state.startListening()
        await state.restoreSession()
        #expect(state.isAuthenticated == true)

        await state.signOut()

        #expect(state.currentUser == nil)
        #expect(state.isAuthenticated == false)
    }

    @Test("Auth state change to signedIn updates user")
    func authStateChangeSignedIn() async throws {
        let mockAuth = MockAuthService()
        let state = AppState(authService: mockAuth)
        state.isLoading = false
        state.startListening()

        try await mockAuth.signInWithGoogle()

        // Give the async stream a moment to propagate
        try await Task.sleep(for: .milliseconds(50))

        #expect(state.currentUser != nil)
        #expect(state.isAuthenticated == true)
    }
}
