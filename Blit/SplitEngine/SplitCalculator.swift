import Foundation

struct SplitCalculator: Sendable {

    static func calculate(
        lineItems: [LineItem],
        participants: [Participant],
        tax: Decimal,
        tip: Decimal,
        mode: SplitMode
    ) -> [ParticipantShare] {
        guard !participants.isEmpty else { return [] }

        switch mode {
        case .itemized:
            return calculateItemized(
                lineItems: lineItems, participants: participants,
                tax: tax, tip: tip
            )
        case .equalSplit:
            return calculateEqualSplit(
                lineItems: lineItems, participants: participants,
                tax: tax, tip: tip
            )
        }
    }

    // MARK: - Itemized

    private static func calculateItemized(
        lineItems: [LineItem],
        participants: [Participant],
        tax: Decimal,
        tip: Decimal
    ) -> [ParticipantShare] {
        var subtotals: [UUID: Decimal] = [:]
        var itemsByParticipant: [UUID: [LineItem]] = [:]

        for p in participants {
            subtotals[p.id] = 0
            itemsByParticipant[p.id] = []
        }

        for item in lineItems {
            guard !item.assignedTo.isEmpty else { continue }
            let count = Decimal(item.assignedTo.count)
            let perPerson = roundCurrency(item.price / count)
            let remainder = item.price - (perPerson * count)

            for (index, pid) in item.assignedTo.enumerated() {
                guard subtotals[pid] != nil else { continue }
                var share = perPerson
                if index == 0 { share += remainder }
                subtotals[pid, default: 0] += share
                itemsByParticipant[pid, default: []].append(item)
            }
        }

        let receiptSubtotal = subtotals.values.reduce(Decimal.zero, +)

        var shares: [ParticipantShare] = []
        var taxRunning = Decimal.zero
        var tipRunning = Decimal.zero

        let sortedParticipants = participants

        for (index, p) in sortedParticipants.enumerated() {
            let pSubtotal = subtotals[p.id, default: 0]
            let isLast = index == sortedParticipants.count - 1

            let pTax: Decimal
            let pTip: Decimal

            if isLast {
                pTax = tax - taxRunning
                pTip = tip - tipRunning
            } else if receiptSubtotal > 0 {
                let ratio = pSubtotal / receiptSubtotal
                pTax = roundCurrency(tax * ratio)
                pTip = roundCurrency(tip * ratio)
            } else {
                pTax = 0
                pTip = 0
            }

            taxRunning += pTax
            tipRunning += pTip

            shares.append(ParticipantShare(
                participantId: p.id,
                subtotal: pSubtotal,
                taxShare: pTax,
                tipShare: pTip,
                total: pSubtotal + pTax + pTip,
                items: itemsByParticipant[p.id, default: []]
            ))
        }

        return shares
    }

    // MARK: - Equal Split

    private static func calculateEqualSplit(
        lineItems: [LineItem],
        participants: [Participant],
        tax: Decimal,
        tip: Decimal
    ) -> [ParticipantShare] {
        let subtotal = lineItems.reduce(Decimal.zero) { $0 + $1.price }
        let grandTotal = subtotal + tax + tip
        let count = Decimal(participants.count)
        let perPerson = roundCurrency(grandTotal / count)
        let remainder = grandTotal - (perPerson * count)

        return participants.enumerated().map { index, p in
            let isFirst = index == 0
            let equalSubtotal = roundCurrency(subtotal / count)
            let equalTax = roundCurrency(tax / count)
            let equalTip = roundCurrency(tip / count)

            let subtotalRemainder = isFirst ? subtotal - equalSubtotal * count : 0
            let taxRemainder = isFirst ? tax - equalTax * count : 0
            let tipRemainder = isFirst ? tip - equalTip * count : 0

            var total = perPerson
            if isFirst { total += remainder }

            return ParticipantShare(
                participantId: p.id,
                subtotal: equalSubtotal + subtotalRemainder,
                taxShare: equalTax + taxRemainder,
                tipShare: equalTip + tipRemainder,
                total: total,
                items: lineItems
            )
        }
    }

    // MARK: - Helpers

    private static func roundCurrency(_ value: Decimal) -> Decimal {
        var result = Decimal()
        var mutableValue = value
        NSDecimalRound(&result, &mutableValue, 2, .bankers)
        return result
    }
}
