import Foundation
import Combine
import SwiftUI

@MainActor
class RoomDetailViewModel: ObservableObject {

    @Published var room: RoomDetail?
    @Published var selectedDateID: String?
    @Published var isLoading = false
    @Published var calendarVM = CalendarStripViewModel()

    func fetchRoomDetail(roomId: String) {
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.room = RoomDetail(
                id: roomId,
                name: "Ideation Room",
                floor: 3,
                capacity: 16,
                imageUrl: "Image",
                description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                facilities: [
                    Facility(id: "1", title: "Wi-Fi", icon: "wifi"),
                    Facility(id: "2", title: "Screen", icon: "screen")
                ],
                // Keeping this to match your model, but UI now uses CalendarStripView
                availableDates: []
            )

            // Example availability rule:
            // - Weekends are unavailable
            // - Additionally, make the 3rd and 7th day from today unavailable (demo)
            self.calendarVM.setAvailability(using: { date in
                let cal = Calendar.current
                let weekday = cal.component(.weekday, from: date) // 1: Sunday ... 7: Saturday
                let isWeekend = (weekday == 1 || weekday == 7)
                let daysFromToday = cal.dateComponents([.day], from: cal.startOfDay(for: Date()), to: cal.startOfDay(for: date)).day ?? 0
                let extraBlocked = (daysFromToday == 3 || daysFromToday == 7)
                return !(isWeekend || extraBlocked)
            })

            self.isLoading = false
        }
    }
}

#Preview {
    RoomDetailView(roomId: "room-1", isExistingBooking: false)
}

