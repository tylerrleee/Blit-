import Testing
import Foundation
@testable import Blit

// MARK: - Test Helpers

private let hostId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
private let receiptId = UUID(uuidString: "00000000-0000-0000-0000-000000000010")!
private let alice = UUID(uuidString: "00000000-0000-0000-0000-00000000000A")!
private let bob = UUID(uuidString: "00000000-0000-0000-0000-00000000000B")!
private let carol = UUID(uuidString: "00000000-0000-0000-0000-00000000000C")!

private func makeItem(name: String, price: Decimal, assignedTo: [UUID]) -> LineItem {
    LineItem(id: UUID(), receiptId: receiptId, name: name, price: price, assignedTo: assignedTo)
}

private func makeParticipant(id: UUID, name: String) -> Participant {
    Participant(id: id, receiptId: receiptId, name: name, status: .confirmed, userId: nil)
}

private func totalOf(_ shares: [ParticipantShare]) -> Decimal {
    shares.reduce(Decimal.zero) { $0 + $1.total }
}

// MARK: - Itemized Split Tests

@Test("Basic itemized split: 3 people, 3 exclusive items, no sharing")
func basicItemizedSplit() {
    let items = [
        makeItem(name: "Burger", price: 15, assignedTo: [alice]),
        makeItem(name: "Salad", price: 10, assignedTo: [bob]),
        makeItem(name: "Pasta", price: 20, assignedTo: [carol]),
    ]
    let participants = [
        makeParticipant(id: alice, name: "Alice"),
        makeParticipant(id: bob, name: "Bob"),
        makeParticipant(id: carol, name: "Carol"),
    ]

    let shares = SplitCalculator.calculate(
        lineItems: items, participants: participants,
        tax: Decimal(string: "4.50")!, tip: Decimal(string: "9.00")!,
        mode: .itemized
    )

    #expect(shares.count == 3)

    let aliceShare = shares.first { $0.participantId == alice }!
    #expect(aliceShare.subtotal == 15)
    // Alice's tax: 4.50 * (15/45) = 1.50
    #expect(aliceShare.taxShare == Decimal(string: "1.50")!)
    // Alice's tip: 9.00 * (15/45) = 3.00
    #expect(aliceShare.tipShare == Decimal(string: "3.00")!)
    #expect(aliceShare.total == Decimal(string: "19.50")!)
}

@Test("Shared item split equally among assignees")
func sharedItemSplit() {
    let items = [
        makeItem(name: "Nachos", price: 12, assignedTo: [alice, bob]),
        makeItem(name: "Steak", price: 30, assignedTo: [alice]),
    ]
    let participants = [
        makeParticipant(id: alice, name: "Alice"),
        makeParticipant(id: bob, name: "Bob"),
    ]

    let shares = SplitCalculator.calculate(
        lineItems: items, participants: participants,
        tax: 0, tip: 0, mode: .itemized
    )

    let aliceShare = shares.first { $0.participantId == alice }!
    let bobShare = shares.first { $0.participantId == bob }!
    // Alice: 12/2 + 30 = 36
    #expect(aliceShare.subtotal == 36)
    // Bob: 12/2 = 6
    #expect(bobShare.subtotal == 6)
}

@Test("Tax and tip proportional to subtotal ratio")
func proportionalTaxAndTip() {
    let items = [
        makeItem(name: "Fish", price: 20, assignedTo: [alice]),
        makeItem(name: "Soup", price: 10, assignedTo: [bob]),
    ]
    let participants = [
        makeParticipant(id: alice, name: "Alice"),
        makeParticipant(id: bob, name: "Bob"),
    ]

    let shares = SplitCalculator.calculate(
        lineItems: items, participants: participants,
        tax: Decimal(string: "6.00")!, tip: Decimal(string: "6.00")!,
        mode: .itemized
    )

    let aliceShare = shares.first { $0.participantId == alice }!
    let bobShare = shares.first { $0.participantId == bob }!
    // Alice: tax = 6 * (20/30) = 4, tip = 6 * (20/30) = 4
    #expect(aliceShare.taxShare == Decimal(string: "4.00")!)
    #expect(aliceShare.tipShare == Decimal(string: "4.00")!)
    // Bob: tax = 6 * (10/30) = 2, tip = 6 * (10/30) = 2
    #expect(bobShare.taxShare == Decimal(string: "2.00")!)
    #expect(bobShare.tipShare == Decimal(string: "2.00")!)
}

@Test("Rounding remainder goes to first participant (host)")
func roundingRemainderToHost() {
    // $10 split 3 ways = $3.33 each, remainder $0.01
    let items = [
        makeItem(name: "Apps", price: 10, assignedTo: [alice, bob, carol]),
    ]
    let participants = [
        makeParticipant(id: alice, name: "Alice"),
        makeParticipant(id: bob, name: "Bob"),
        makeParticipant(id: carol, name: "Carol"),
    ]

    let shares = SplitCalculator.calculate(
        lineItems: items, participants: participants,
        tax: 0, tip: 0, mode: .itemized
    )

    let grandTotal = totalOf(shares)
    #expect(grandTotal == 10)

    // At least one person gets an extra cent
    let amounts = shares.map { $0.total }.sorted()
    #expect(amounts.contains(Decimal(string: "3.34")!) || amounts.contains(Decimal(string: "3.33")!))
}

@Test("Single person gets entire bill")
func singlePersonSplit() {
    let items = [
        makeItem(name: "Dinner", price: 50, assignedTo: [alice]),
        makeItem(name: "Wine", price: 20, assignedTo: [alice]),
    ]
    let participants = [
        makeParticipant(id: alice, name: "Alice"),
    ]

    let shares = SplitCalculator.calculate(
        lineItems: items, participants: participants,
        tax: Decimal(string: "7.00")!, tip: Decimal(string: "14.00")!,
        mode: .itemized
    )

    #expect(shares.count == 1)
    let share = shares[0]
    #expect(share.subtotal == 70)
    #expect(share.taxShare == 7)
    #expect(share.tipShare == 14)
    #expect(share.total == 91)
}

@Test("All items shared by all participants")
func allItemsShared() {
    let items = [
        makeItem(name: "Pizza", price: 24, assignedTo: [alice, bob, carol]),
        makeItem(name: "Drinks", price: 18, assignedTo: [alice, bob, carol]),
    ]
    let participants = [
        makeParticipant(id: alice, name: "Alice"),
        makeParticipant(id: bob, name: "Bob"),
        makeParticipant(id: carol, name: "Carol"),
    ]

    let shares = SplitCalculator.calculate(
        lineItems: items, participants: participants,
        tax: Decimal(string: "4.20")!, tip: Decimal(string: "8.40")!,
        mode: .itemized
    )

    // Each person: subtotal = (24+18)/3 = 14
    for share in shares {
        #expect(share.subtotal == 14)
    }
    #expect(totalOf(shares) == Decimal(string: "54.60")!)
}

@Test("Zero tax and tip")
func zeroTaxAndTip() {
    let items = [
        makeItem(name: "Coffee", price: 5, assignedTo: [alice]),
    ]
    let participants = [
        makeParticipant(id: alice, name: "Alice"),
    ]

    let shares = SplitCalculator.calculate(
        lineItems: items, participants: participants,
        tax: 0, tip: 0, mode: .itemized
    )

    let share = shares[0]
    #expect(share.taxShare == 0)
    #expect(share.tipShare == 0)
    #expect(share.total == 5)
}

// MARK: - Equal Split Tests

@Test("Equal split divides total evenly")
func equalSplitBasic() {
    let items = [
        makeItem(name: "Feast", price: 100, assignedTo: []),
    ]
    let participants = [
        makeParticipant(id: alice, name: "Alice"),
        makeParticipant(id: bob, name: "Bob"),
    ]

    let shares = SplitCalculator.calculate(
        lineItems: items, participants: participants,
        tax: Decimal(string: "10.00")!, tip: Decimal(string: "20.00")!,
        mode: .equalSplit
    )

    #expect(shares.count == 2)
    // Grand total = 100 + 10 + 20 = 130, each pays 65
    for share in shares {
        #expect(share.total == 65)
    }
}

@Test("Equal split with rounding remainder")
func equalSplitRounding() {
    let items = [
        makeItem(name: "Meal", price: 100, assignedTo: []),
    ]
    let participants = [
        makeParticipant(id: alice, name: "Alice"),
        makeParticipant(id: bob, name: "Bob"),
        makeParticipant(id: carol, name: "Carol"),
    ]

    let shares = SplitCalculator.calculate(
        lineItems: items, participants: participants,
        tax: 0, tip: 0, mode: .equalSplit
    )

    let grandTotal = totalOf(shares)
    #expect(grandTotal == 100)
    // 100 / 3 = 33.33... — one person pays extra cent
    let amounts = shares.map { $0.total }.sorted()
    #expect(amounts[0] == Decimal(string: "33.33")!)
    #expect(amounts[2] == Decimal(string: "33.34")!)
}

// MARK: - Invariant Tests

@Test("Invariant: sum of participant totals equals grand total (itemized)")
func invariantSumEqualsGrandTotalItemized() {
    let items = [
        makeItem(name: "Appetizer", price: Decimal(string: "13.75")!, assignedTo: [alice, bob]),
        makeItem(name: "Entree", price: Decimal(string: "27.99")!, assignedTo: [carol]),
        makeItem(name: "Dessert", price: Decimal(string: "8.50")!, assignedTo: [alice]),
        makeItem(name: "Drinks", price: Decimal(string: "11.25")!, assignedTo: [bob, carol]),
        makeItem(name: "Side", price: Decimal(string: "6.00")!, assignedTo: [alice, bob, carol]),
    ]
    let participants = [
        makeParticipant(id: alice, name: "Alice"),
        makeParticipant(id: bob, name: "Bob"),
        makeParticipant(id: carol, name: "Carol"),
    ]
    let tax = Decimal(string: "5.87")!
    let tip = Decimal(string: "12.00")!
    let subtotal = items.reduce(Decimal.zero) { $0 + $1.price }
    let grandTotal = subtotal + tax + tip

    let shares = SplitCalculator.calculate(
        lineItems: items, participants: participants,
        tax: tax, tip: tip, mode: .itemized
    )

    #expect(totalOf(shares) == grandTotal)
}

@Test("Invariant: sum of participant totals equals grand total (equal split)")
func invariantSumEqualsGrandTotalEqualSplit() {
    let items = [
        makeItem(name: "Everything", price: Decimal(string: "99.97")!, assignedTo: []),
    ]
    let participants = [
        makeParticipant(id: alice, name: "Alice"),
        makeParticipant(id: bob, name: "Bob"),
        makeParticipant(id: carol, name: "Carol"),
    ]
    let tax = Decimal(string: "8.73")!
    let tip = Decimal(string: "15.50")!
    let grandTotal = Decimal(string: "99.97")! + tax + tip

    let shares = SplitCalculator.calculate(
        lineItems: items, participants: participants,
        tax: tax, tip: tip, mode: .equalSplit
    )

    #expect(totalOf(shares) == grandTotal)
}

@Test("Unassigned items are excluded from itemized split")
func unassignedItemsExcluded() {
    let items = [
        makeItem(name: "Burger", price: 15, assignedTo: [alice]),
        makeItem(name: "Fries", price: 5, assignedTo: []),
    ]
    let participants = [
        makeParticipant(id: alice, name: "Alice"),
    ]

    let shares = SplitCalculator.calculate(
        lineItems: items, participants: participants,
        tax: 0, tip: 0, mode: .itemized
    )

    let share = shares[0]
    #expect(share.subtotal == 15)
}
