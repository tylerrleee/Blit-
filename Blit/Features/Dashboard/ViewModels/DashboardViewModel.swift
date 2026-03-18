import Foundation
import Observation

@MainActor @Observable final class DashboardViewModel {
    var recentReceipts: [Receipt] = []
    var isLoading = false
    var errorMessage: String?
    let currentUser: User

    private let databaseService: any DatabaseService

    init(databaseService: any DatabaseService, currentUser: User) {
        self.databaseService = databaseService
        self.currentUser = currentUser
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting: String
        switch hour {
        case 5..<12: timeGreeting = "Good morning"
        case 12..<17: timeGreeting = "Good afternoon"
        case 17..<22: timeGreeting = "Good evening"
        default: timeGreeting = "Good night"
        }
        let firstName = currentUser.name.components(separatedBy: " ").first ?? currentUser.name
        return "\(timeGreeting),\n\(firstName)"
    }

    var total: Decimal {
        recentReceipts.reduce(Decimal.zero) { $0 + $1.subtotal + $1.tax + $1.tip }
    }

    func loadReceipts() async {
        isLoading = true
        errorMessage = nil
        do {
            recentReceipts = try await databaseService.fetchUserReceipts(userId: currentUser.id)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func participantCount(for receiptId: UUID) async -> Int {
        (try? await databaseService.fetchParticipants(receiptId: receiptId))?.count ?? 0
    }

    func dismissError() {
        errorMessage = nil
    }
}
