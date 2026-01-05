import Foundation

struct AirtableResponse<T: Decodable>: Decodable {
    let records: [T]
}
