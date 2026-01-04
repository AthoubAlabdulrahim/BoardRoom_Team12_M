//
//  EmployeeService.swift
//  BoardRoomTeam12
//
//  Created by Athoub on 03/07/1447 AH.
//

import Foundation

// Central error type used across networking
enum APIError: Error, LocalizedError {
    case invalidURL
    case badStatus(Int)
    case decoding(Error)
    case transport(Error)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL."
        case .badStatus(let code):
            return "Server returned status code \(code)."
        case .decoding(let err):
            return "Failed to decode response: \(err.localizedDescription)"
        case .transport(let err):
            return "Network error: \(err.localizedDescription)"
        case .emptyResponse:
            return "Empty response from server."
        }
    }
}

protocol EmployeeService {
    // Fetch at most one employee by job number
    func fetchEmployee(jobNumber: Int) async throws -> RecordsResponse
}

struct DefaultEmployeeService: EmployeeService {

    // MARK: - Small API builder (replaces APIConstants/EmployeeAPI)
    private func authorizedRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Secrets.airtableAPIToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private func employeesURL(jobNumber: Int) throws -> URL {
        guard var components = URLComponents(string: Secrets.airtableBaseURLString) else {
            throw APIError.invalidURL
        }
        // Airtable filter formula for numeric field
        let filter = "({EmployeeNumber}=\(jobNumber))"
        components.queryItems = [
            URLQueryItem(name: "filterByFormula", value: filter),
            URLQueryItem(name: "maxRecords", value: "1"),
            URLQueryItem(name: "pageSize", value: "1")
        ]
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        return url
    }

    // MARK: - Networking
    func fetchEmployee(jobNumber: Int) async throws -> RecordsResponse {
        let url = try employeesURL(jobNumber: jobNumber)
        let request = authorizedRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                throw APIError.emptyResponse
            }
            guard 200..<300 ~= http.statusCode else {
                throw APIError.badStatus(http.statusCode)
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(RecordsResponse.self, from: data)
            } catch {
                throw APIError.decoding(error)
            }
        } catch {
            throw APIError.transport(error)
        }
    }
}
