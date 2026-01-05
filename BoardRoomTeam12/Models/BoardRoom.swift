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

    // why we have used this codingkeys
    // the response from api was different so we just make them to the labels we have used
    // for example in api reponse it is floor_no and in our app we are using floorNo in camel case
    // so we did flootNo = floor_no etc
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case floorNo = "floor_no"
        case seatNo = "seat_no"
        case imageURL = "image_url"
        case facilities = "facilities"
        case description = "description"
    }
}
