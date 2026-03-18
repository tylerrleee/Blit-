import SwiftUI

extension Color {
    static let blitOrange = Color(red: 230/255, green: 126/255, blue: 34/255)   // #E67E22
    static let blitDark = Color(red: 44/255, green: 62/255, blue: 80/255)       // #2C3E50
    static let blitBackground = Color(red: 135/255, green: 206/255, blue: 250/255) // Light sky blue from mockup
}

extension ShapeStyle where Self == Color {
    static var blitOrange: Color { .blitOrange }
    static var blitDark: Color { .blitDark }
    static var blitBackground: Color { .blitBackground }
}
