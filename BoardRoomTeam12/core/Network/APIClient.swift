import Foundation

// why we use final becuase it will not allow any other class to inherit this or extend this class
final class APIClient {

    // we have created an instance
    static let shared = APIClient()
    // this private inti() {} means that there will be only one instance of APIClient means it will use the same header,token header etc
    // this line will let you call this class and its functions directly like
    // APIClient.shared.get(url), APIClient.shared.post(url) instead of declaring it in every file
    private init() {}

    // get<T: Decodable> here T is used as type it means the get function will return any type of data and decoable will read JSON
    // so basically it says get function will return any data like employees, bookings whatever their types are
    // so from here we will send the url and authorizedRequest is already defined in secrets and it will get three parameters
    // in which data is optional, below here we see that we are sending the url and the method
    //rest is the same for requests below get, post, delete, patch
    // asycn throws means the function will wait and throw error if internet goes down, api fails etc
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

    
    //this is the main function where we will send our request and recieve the response from the api
    
    private func send<T: Decodable>(_ request: URLRequest) async throws -> T {

        do {
            // this line will send data and bring the response of request
            let (data, response) = try await URLSession.shared.data(for: request)

            // this will check if the response is HTTP or not else will throw error
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
                let decoder = JSONDecoder() // this will convert JSON to swift class
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
