import CoreGraphics

protocol OCRProvider: Sendable {
    func recognizeText(from image: CGImage) async throws -> [OCRTextBlock]
}
