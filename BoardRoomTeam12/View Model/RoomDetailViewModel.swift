//View Model/RoomDetailViewModel

import Foundation
import Combine
import SwiftUI

@MainActor
class RoomDetailViewModel: ObservableObject {
    @Published var room: RoomRecord?
    @Published var calendarVM = CalendarStripViewModel()
    
    func setup(with selectedRoom: RoomRecord) {
        self.room = selectedRoom
        // إعداد توفر الأيام
        self.calendarVM.setAvailability { date in
            let day = Calendar.current.component(.weekday, from: date)
            return day != 1 && day != 7 // متاح ما عدا الجمعة والسبت
        }
    }
}
