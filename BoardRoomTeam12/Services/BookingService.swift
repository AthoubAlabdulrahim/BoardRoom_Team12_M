import Foundation

final class BookingService {

    func fetchBookings() async throws -> [Booking] {
        let response: BookingsResponse =
            try await APIClient.shared.get(Endpoints.bookings)
        return response.records
    }

    func createBooking(fields: BookingFields) async throws {
        let body = try JSONEncoder().encode(["fields": fields])
        let _: Booking =
            try await APIClient.shared.post(Endpoints.bookings, body: body)
    }

    func deleteBooking(id: String) async throws {
        let _: EmptyResponse =
            try await APIClient.shared.delete(Endpoints.booking(id: id))
    }
    func updateBooking(id: String, fields: BookingFields) async throws {
            let body = try JSONEncoder().encode(["fields": fields])
            let _: Booking =
                try await APIClient.shared.patch(Endpoints.booking(id: id), body: body)
        }
}

struct EmptyResponse: Decodable {}
