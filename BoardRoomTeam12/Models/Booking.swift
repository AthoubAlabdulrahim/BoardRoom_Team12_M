import Foundation

struct BookingsResponse: Decodable {
    let records: [Booking]
}

struct Booking: Identifiable, Decodable {
    let id: String
    let fields: BookingFields
}

struct BookingFields: Codable {
    let employeeID: String?
    let boardroomID: String
    let date: Int        
    let status: String?

    enum CodingKeys: String, CodingKey {
        case employeeID = "employee_id"
        case boardroomID = "boardroom_id"
        case date
        case status
    }
}
