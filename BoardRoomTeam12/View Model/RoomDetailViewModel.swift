import Foundation
import Combine
import SwiftUI

@MainActor
class RoomDetailViewModel: ObservableObject {

    @Published var room: RoomDetail?
    @Published var selectedDateID: String?
    @Published var isLoading = false
    

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
                availableDates: [
                    BookingDate(id: "1", day: "Thu", date: "16", isAvailable: false),
                    BookingDate(id: "2", day: "Sun", date: "19", isAvailable: true),
                    BookingDate(id: "3", day: "Mon", date: "20", isAvailable: true),
                    BookingDate(id: "4", day: "Wed", date: "22", isAvailable: false),
                    BookingDate(id: "5", day: "Wed", date: "22", isAvailable: false),
                    BookingDate(id: "6", day: "Thru", date: "22", isAvailable: false),
                    BookingDate(id: "7", day: "Wed", date: "22", isAvailable: true),
                    BookingDate(id: "8", day: "Friday", date: "22", isAvailable: true)
                ]
            )
            self.isLoading = false
        }
    }
}

#Preview {
    RoomDetailView(roomId: "room-1", isExistingBooking: false)
}
