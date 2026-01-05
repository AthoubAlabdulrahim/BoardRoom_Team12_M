import Foundation

struct BoardRoomsResponse: Decodable {
    let records: [BoardRoom]
}

struct BoardRoom: Identifiable, Decodable {
    let id: String
    let fields: BoardRoomFields
}

struct BoardRoomFields: Decodable {
    let name: String
    let floorNo: Int
    let seatNo: Int
    let imageURL: String
    let facilities: [String]
    let description: String

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case floorNo = "floor_no"
        case seatNo = "seat_no"
        case imageURL = "image_url"
        case facilities = "facilities"
        case description = "description"
    }
}
