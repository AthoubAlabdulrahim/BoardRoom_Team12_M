import Foundation

final class APIClient {

    static let shared = APIClient()
    private init() {}

    func get<T: Decodable>(_ url: URL) async throws -> T {
        let request = Secrets.authorizedRequest(url: url, method: "GET")
        return try await send(request)
    }

    func post<T: Decodable>(_ url: URL, body: Data) async throws -> T {
        let request = Secrets.authorizedRequest(url: url, method: "POST", body: body)
        return try await send(request)
    }

    func patch<T: Decodable>(_ url: URL, body: Data) async throws -> T {
        let request = Secrets.authorizedRequest(url: url, method: "PATCH", body: body)
        return try await send(request)
    }

    func delete<T: Decodable>(_ url: URL) async throws -> T {
        let request = Secrets.authorizedRequest(url: url, method: "DELETE")
        return try await send(request)
    }

    private func send<T: Decodable>(_ request: URLRequest) async throws -> T {

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            switch http.statusCode {
            case 200...299:
                break
            case 401:
                throw APIError.unauthorized
            case 403:
                throw APIError.forbidden
            case 404:
                throw APIError.notFound
            case 500...599:
                throw APIError.serverError
            default:
                throw APIError.unknown(statusCode: http.statusCode)
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .useDefaultKeys
                return try decoder.decode(T.self, from: data)

            } catch {
                throw APIError.decodingFailed
            }

        } catch let error as URLError {
            if error.code == .notConnectedToInternet {
                throw APIError.noInternet
            } else {
                throw APIError.requestFailed
            }
        }
    }

}
