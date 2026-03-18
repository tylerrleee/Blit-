import Foundation
import CoreGraphics

struct OCRTextBlock: Sendable, Hashable {
    let text: String
    let confidence: Float
    let boundingBox: CGRect
}
