import Testing
import Foundation
@testable import Blit

@Suite("DashboardViewModel")
@MainActor
struct DashboardViewModelTests {

    private func makeSUT() -> (DashboardViewModel, MockDatabaseService) {
        let mockDB = MockDatabaseService()
        let mockUser = User(
            id: UUID(),
            email: "alex@test.com",
            googleAuthId: nil,
            name: "Alex Rivera",
            avatarURL: nil
        )
        let vm = DashboardViewModel(databaseService: mockDB, currentUser: mockUser)
        return (vm, mockDB)
    }

    @Test("Initial state: not loading, empty receipts")
    func initialState() {
        let (vm, _) = makeSUT()
        #expect(vm.isLoading == false)
        #expect(vm.recentReceipts.isEmpty)
        #expect(vm.errorMessage == nil)
    }

    @Test("greeting returns time-appropriate greeting with first name")
    func greetingUsesFirstName() {
        let (vm, _) = makeSUT()
        let greeting = vm.greeting
        #expect(greeting.contains("Alex"))
    }

    @Test("loadReceipts fetches from database service")
    func loadReceiptsFetches() async {
        let (vm, mockDB) = makeSUT()
        let receipt = Receipt(
            id: UUID(), hostId: vm.currentUser.id,
            restaurant: "Test Restaurant", subtotal: 50, tax: 5, tip: 10,
            status: .closed, imageURL: nil, createdAt: Date()
        )
        mockDB.receipts = [receipt]

        await vm.loadReceipts()

        #expect(vm.recentReceipts.count == 1)
        #expect(vm.recentReceipts[0].restaurant == "Test Restaurant")
        #expect(vm.isLoading == false)
    }

    @Test("loadReceipts sets error on failure")
    func loadReceiptsError() async {
        let (vm, mockDB) = makeSUT()
        mockDB.shouldFail = true

        await vm.loadReceipts()

        #expect(vm.errorMessage != nil)
        #expect(vm.isLoading == false)
    }

    @Test("participantCount returns count for receipt")
    func participantCount() async {
        let (vm, mockDB) = makeSUT()
        let receiptId = UUID()
        let receipt = Receipt(
            id: receiptId, hostId: vm.currentUser.id,
            restaurant: "Test", subtotal: 50, tax: 5, tip: 10,
            status: .active, imageURL: nil, createdAt: Date()
        )
        mockDB.receipts = [receipt]
        mockDB.participants = [
            Participant(id: UUID(), receiptId: receiptId, name: "Alice", status: .confirmed, userId: nil),
            Participant(id: UUID(), receiptId: receiptId, name: "Bob", status: .selecting, userId: nil),
        ]

        await vm.loadReceipts()
        let count = await vm.participantCount(for: receiptId)
        #expect(count == 2)
    }

    @Test("dismissError clears error message")
    func dismissError() {
        let (vm, _) = makeSUT()
        vm.errorMessage = "Some error"
        vm.dismissError()
        #expect(vm.errorMessage == nil)
    }
}
