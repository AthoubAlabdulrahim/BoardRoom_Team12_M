import Foundation
import Combine

@MainActor
final class RoomDetailViewModel: ObservableObject {

    @Published var calendarVM = CalendarStripViewModel()

    private let bookingService = BookingService()
    private let defaultStatus: String = "Confirmed"
    private let calendar = Calendar.current

    private var cancellables = Set<AnyCancellable>()

    init() {
        // ✅ Forward CalendarStrip changes so RoomDetailView updates canUpdate properly
        calendarVM.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    private func normalizeToStartOfDay(_ ts: Int) -> Int {
        let seconds: TimeInterval = ts > 2_000_000_000_000 ? TimeInterval(ts) / 1000.0 : TimeInterval(ts)
        let d = Date(timeIntervalSince1970: seconds)
        return Int(calendar.startOfDay(for: d).timeIntervalSince1970)
    }

    func setup(bookedTimestamps: [Int], allowTimestamp: Int?) {
        let bookedSet = Set(bookedTimestamps.map(normalizeToStartOfDay))
        let allow = allowTimestamp.map(normalizeToStartOfDay)

        calendarVM.setAvailability { [calendar] date in
            let dayTS = Int(calendar.startOfDay(for: date).timeIntervalSince1970)

            // ✅ Allow own booking day in edit mode
            if let allow = allow, dayTS == allow { return true }

            // ✅ Weekends allowed
            return !bookedSet.contains(dayTS)
        }
    }

    func createBooking(roomID: String) async throws {
        guard let employeeID = UserSession.shared.employeeID else {
            throw APIError.custom(message: "User not logged in")
        }

        let fields = BookingFields(
            employeeID: employeeID,
            boardroomID: roomID,
            date: calendarVM.selectedUnixTimestamp,
            status: defaultStatus
        )

        try await bookingService.createBooking(fields: fields)
    }

    func updateBooking(booking: Booking, roomID: String) async throws {
        guard let employeeID = UserSession.shared.employeeID else {
            throw APIError.custom(message: "User not logged in")
        }

        guard booking.fields.employeeID == employeeID else {
            throw APIError.custom(message: "You can only update your own booking")
        }

        let fields = BookingFields(
            employeeID: employeeID,
            boardroomID: roomID,
            date: calendarVM.selectedUnixTimestamp,
            status: defaultStatus
        )

        try await bookingService.updateBooking(id: booking.id, fields: fields)
    }

    func deleteBooking(booking: Booking) async throws {
        guard let employeeID = UserSession.shared.employeeID else {
            throw APIError.custom(message: "User not logged in")
        }

        guard booking.fields.employeeID == employeeID else {
            throw APIError.custom(message: "You can only delete your own booking")
        }

        try await bookingService.deleteBooking(id: booking.id)
    }
}
