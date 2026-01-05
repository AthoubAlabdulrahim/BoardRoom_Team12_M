import Foundation
import Combine
@MainActor
final class BookingViewModel: ObservableObject {

    @Published var bookings: [Booking] = []
    @Published var rooms: [BoardRoom] = []
    @Published var isLoading = false

    private let bookingService = BookingService()
    private let roomService = BoardRoomService()
    private let calendar = Calendar.current

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do { rooms = try await roomService.fetchRooms() }
        catch { print("Rooms Error:", error) }

        do { bookings = try await bookingService.fetchBookings() }
        catch { print("Booking Error:", error) }
    }

    private func normalizeToStartOfDay(_ ts: Int) -> Int {
        let seconds: TimeInterval = ts > 2_000_000_000_000 ? TimeInterval(ts) / 1000.0 : TimeInterval(ts)
        let d = Date(timeIntervalSince1970: seconds)
        return Int(calendar.startOfDay(for: d).timeIntervalSince1970)
    }

    private var todayStart: Int {
        Int(calendar.startOfDay(for: Date()).timeIntervalSince1970)
    }

    private var upcomingBookings: [Booking] {
        bookings.filter { normalizeToStartOfDay($0.fields.date) >= todayStart }
    }

    var myBookings: [Booking] {
        guard let emp = UserSession.shared.employeeID else { return [] }
        return upcomingBookings
            .filter { $0.fields.employeeID == emp }
            .sorted { normalizeToStartOfDay($0.fields.date) < normalizeToStartOfDay($1.fields.date) }
    }

    func bookingsForRoom(_ roomID: String) -> [Booking] {
        upcomingBookings
            .filter { $0.fields.boardroomID == roomID }
            .sorted { normalizeToStartOfDay($0.fields.date) < normalizeToStartOfDay($1.fields.date) }
    }

   
    func myBookingForRoom(_ roomID: String) -> Booking? {
        myBookings
            .filter { $0.fields.boardroomID == roomID }
            .min { normalizeToStartOfDay($0.fields.date) < normalizeToStartOfDay($1.fields.date) }
    }

    
    var nextMyBooking: Booking? {
        myBookings.first
    }
}
