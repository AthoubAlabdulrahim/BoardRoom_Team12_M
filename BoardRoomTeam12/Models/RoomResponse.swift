//
//  RoomResponse.swift
//  BoardRoomTeam12
//
//  Created by Athoub Alabdulrahim on 15/07/1447 AH.
//
import Foundation

struct RoomResponse: Codable {
    let records: [RoomRecord]
}

struct RoomRecord: Identifiable, Codable {
    let id: String
    let fields: RoomFields
}

struct RoomFields: Codable {
    let name: String
    let floorNo: Int
    let seatNo: Int
    let description: String
    let facilities: [String]
    let imageURL: String

    enum CodingKeys: String, CodingKey {
        case name
        case floorNo = "floor_no"
        case seatNo = "seat_no"
        case description, facilities
        case imageURL = "image_url"
    }
}
