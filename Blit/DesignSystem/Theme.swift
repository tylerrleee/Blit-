import SwiftUI

enum BlitSpacing {
    static let xxsmall: CGFloat = 4
    static let xsmall: CGFloat = 6
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let xlarge: CGFloat = 32
    static let xxlarge: CGFloat = 48
}

enum BlitCornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xlarge: CGFloat = 20
    static let pill: CGFloat = 999
}

enum BlitFont {
    static let largeTitle: Font = .system(size: 28, weight: .bold)
    static let title: Font = .system(size: 22, weight: .bold)
    static let headline: Font = .system(size: 17, weight: .semibold)
    static let body: Font = .system(size: 17, weight: .regular)
    static let callout: Font = .system(size: 16, weight: .regular)
    static let subheadline: Font = .system(size: 15, weight: .regular)
    static let footnote: Font = .system(size: 13, weight: .regular)
    static let caption: Font = .system(size: 12, weight: .regular)
    static let sectionHeader: Font = .system(size: 13, weight: .bold)
}
