import Foundation
import Combine

final class CalendarStripViewModel: ObservableObject {
    @Published var selectedDate: Date
    @Published private(set) var days: [Date] = []

    private let calendar: Calendar

    init(
        calendar: Calendar = .current,
        initialSelected: Date = Date(),
        daysBefore: Int = 14,
        daysAfter: Int = 14
    ) {
        self.calendar = calendar
        self.selectedDate = initialSelected
        buildDays(around: initialSelected, daysBefore: daysBefore, daysAfter: daysAfter)
    }

    func buildDays(around center: Date, daysBefore: Int, daysAfter: Int) {
        let start = calendar.date(byAdding: .day, value: -daysBefore, to: center) ?? center
        let end = calendar.date(byAdding: .day, value: daysAfter, to: center) ?? center

        var result: [Date] = []
        var d = start
        while d <= end {
            result.append(d)
            d = calendar.date(byAdding: .day, value: 1, to: d) ?? d
        }

        days = result
    }

    func select(_ date: Date) {
        selectedDate = date
    }

    func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }

    func weekdayText(for date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "EEE"      // Thu, Sun, Mon...
        return f.string(from: date)
    }

    func dayNumber(for date: Date) -> String {
        let day = calendar.component(.day, from: date)
        return String(day)
    }
}
