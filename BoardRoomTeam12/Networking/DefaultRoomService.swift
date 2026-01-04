//
//  DefaultRoomService.swift
//  BoardRoomTeam12
//
//  Created by Athoub Alabdulrahim on 15/07/1447 AH.
//
/*
import Foundation

protocol RoomService {
    func fetchRooms() async throws -> [RoomRecord]
}

struct DefaultRoomService: RoomService {
    func fetchRooms() async throws -> [RoomRecord] {
        guard let url = URL(string: Secrets.roomsURLString) else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(Secrets.airtableAPIToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw APIError.badStatus((response as? HTTPURLResponse)?.statusCode ?? 500)
        }
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(RoomResponse.self, from: data)
        return decoded.records
    }
}
*/
