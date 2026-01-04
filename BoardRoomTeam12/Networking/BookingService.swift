//
//  BookingService.swift
//  BoardRoomTeam12
//
//  Created by Athoub Alabdulrahim on 03/07/1447 AH.
//
// Networking/BookingService.swift
import Foundation

protocol BookingService {
    func fetchAllBookings() async throws -> [BookingRecord]
}

struct DefaultBookingService: BookingService {
    func fetchAllBookings() async throws -> [BookingRecord] {
        guard let url = URL(string: Secrets.bookingsURLString) else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Secrets.airtableAPIToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw APIError.badStatus((response as? HTTPURLResponse)?.statusCode ?? 500)
        }
        
        let decoder = JSONDecoder()
        let decodedResponse = try decoder.decode(BookingResponse.self, from: data)
        return decodedResponse.records
    }
}
