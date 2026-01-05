import Foundation

// Generic wrapper for Airtable API responses.
// Airtable usually returns data in the format: { "records": [ ... ] }
// This struct lets us reuse the same response type for any table/model
// (Employees, Boardrooms, Bookings, etc.) as long as the model is Decodable.
struct AirtableResponse<T: Decodable>: Decodable {
    let records: [T]
}
