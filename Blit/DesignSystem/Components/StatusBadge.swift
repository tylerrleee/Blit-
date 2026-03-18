import SwiftUI

struct StatusBadge: View {
    let status: ReceiptStatus

    var body: some View {
        Text(displayText)
            .font(BlitFont.caption)
            .fontWeight(.semibold)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, BlitSpacing.small)
            .padding(.vertical, BlitSpacing.xxsmall)
            .background(backgroundColor, in: Capsule())
    }

    private var displayText: String {
        switch status {
        case .draft: "DRAFT"
        case .active: "ACTIVE"
        case .settling: "SETTLING"
        case .closed: "COMPLETED"
        }
    }

    private var foregroundColor: Color {
        switch status {
        case .draft: .gray
        case .active: .blue
        case .settling: Color.blitOrange
        case .closed: .green
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .draft: Color.gray.opacity(0.15)
        case .active: Color.blue.opacity(0.15)
        case .settling: Color.blitOrange.opacity(0.15)
        case .closed: Color.green.opacity(0.15)
        }
    }
}
