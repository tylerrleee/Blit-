import Foundation
import Observation

@MainActor @Observable final class LoginViewModel {
    var isLoading = false
    var errorMessage: String?

    private let authService: any AuthService

    init(authService: any AuthService) {
        self.authService = authService
    }

    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil

        do {
            try await authService.signInWithGoogle()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func dismissError() {
        errorMessage = nil
    }
}
