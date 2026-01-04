//
//  EmployeeAPI.swift
//  BoardRoomTeam12
//
//  Created by Athoub  on 03/07/1447 AH.
//

import Foundation

enum EmployeeAPI {
    // Build authorized GET request
    static func authorizedRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Secrets.airtableAPIToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    // Build a URL that filters by EmployeeNumber, returning at most 1 record
    // Airtable filter formula for numeric field: ({EmployeeNumber}=112233)
    static func employeesURL(jobNumber: Int) throws -> URL {
        guard var components = URLComponents(string: Secrets.airtableBaseURLString) else {
            throw APIError.invalidURL
        }
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
}
