import Foundation

struct BookingDate: Identifiable, Decodable {
    let id: String
    let day: String
    let date: String
    let isAvailable: Bool
}
