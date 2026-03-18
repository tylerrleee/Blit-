import Foundation

enum AppError: LocalizedError, Sendable {
    case authFailed(message: String)
    case networkError(underlying: Error)
    case ocrFailed(message: String)
    case parsingFailed(message: String)
    case databaseError(message: String)
    case validationError(message: String)
    case notFound(resource: String)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .authFailed(let message):
            return "Authentication failed: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .ocrFailed(let message):
            return "Receipt scan failed: \(message)"
        case .parsingFailed(let message):
            return "Could not read receipt: \(message)"
        case .databaseError(let message):
            return "Database error: \(message)"
        case .validationError(let message):
            return message
        case .notFound(let resource):
            return "\(resource) not found"
        case .unauthorized:
            return "You don't have permission to perform this action"
        }
    }
}

extension AppError: Equatable {
    static func == (lhs: AppError, rhs: AppError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
}
