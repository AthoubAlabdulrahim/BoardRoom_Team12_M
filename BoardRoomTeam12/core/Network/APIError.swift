import Foundation

enum APIError: LocalizedError {

    
    case invalidURL
    case noInternet
    case requestFailed
    case invalidResponse
    case decodingFailed

    
    case unauthorized          // 401
    case forbidden             // 403
    case notFound              // 404
    case serverError            // 5xx
    case unknown(statusCode: Int)

    
    case custom(message: String)

    
    var errorDescription: String? {
        switch self {

        case .invalidURL:
            return "Invalid request. Please try again."

        case .noInternet:
            return "No internet connection."

        case .requestFailed:
            return "Request failed. Please try again."

        case .invalidResponse:
            return "Invalid server response."

        case .decodingFailed:
            return "Unable to read server data."

        case .unauthorized:
            return "Session expired. Please login again."

        case .forbidden:
            return "You are not allowed to perform this action."

        case .notFound:
            return "Requested data not found."

        case .serverError:
            return "Server is temporarily unavailable."

        case .unknown(let code):
            return "Unexpected error occurred. Code: \(code)"

        case .custom(let message):
            return message
        }
    }
}
