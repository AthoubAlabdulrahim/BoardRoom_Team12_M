//
// Models/RoomDetail

import Foundation

struct RoomDetail: Identifiable, Decodable {
    let id: String
    let name: String
    let floor: Int
    let capacity: Int
    let imageUrl: String
    let description: String
    let facilities: [Facility]
    let availableDates: [BookingDate]
}

struct Facility: Identifiable, Decodable {
    let id: String
    let title: String
    let icon: String
}

struct Title: Identifiable, Decodable{
    let id: String
    let title: String
}
