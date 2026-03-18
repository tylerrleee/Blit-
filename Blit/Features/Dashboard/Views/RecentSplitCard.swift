import SwiftUI

struct RecentSplitCard: View {
    let receipt: Receipt
    let participantCount: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: BlitSpacing.xxsmall) {
                Text(receipt.restaurant)
                    .font(BlitFont.headline)
                    .foregroundStyle(Color.blitDark)

                Text("\(formattedDate) \u{2022} \(participantCount) people")
                    .font(BlitFont.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: BlitSpacing.xxsmall) {
                Text(formattedTotal)
                    .font(BlitFont.headline)
                    .foregroundStyle(Color.blitDark)

                StatusBadge(status: receipt.status)
            }
        }
        .padding(BlitSpacing.medium)
        .background(Color.white, in: RoundedRectangle(cornerRadius: BlitCornerRadius.medium))
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: receipt.createdAt)
    }

    private var formattedTotal: String {
        let total = receipt.subtotal + receipt.tax + receipt.tip
        let number = NSDecimalNumber(decimal: total)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: number) ?? "$0.00"
    }
}
