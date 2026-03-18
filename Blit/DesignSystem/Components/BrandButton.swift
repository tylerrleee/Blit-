import SwiftUI

enum BrandButtonStyle {
    case primary    // Dark filled, white text
    case secondary  // White/outlined
}

struct BrandButton: View {
    let title: String
    let icon: String?
    let style: BrandButtonStyle
    let isLoading: Bool
    let action: () -> Void

    init(
        _ title: String,
        icon: String? = nil,
        style: BrandButtonStyle = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: BlitSpacing.small) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.body)
                    }
                    Text(title)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: BlitCornerRadius.medium))
            .foregroundStyle(foregroundColor)
            .overlay {
                if style == .secondary {
                    RoundedRectangle(cornerRadius: BlitCornerRadius.medium)
                        .stroke(Color.blitDark.opacity(0.3), lineWidth: 1.5)
                }
            }
        }
        .disabled(isLoading)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: Color.blitDark
        case .secondary: Color.white
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: .white
        case .secondary: Color.blitDark
        }
    }
}
