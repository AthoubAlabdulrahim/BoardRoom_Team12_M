import Foundation
import Combine

final class CalendarStripViewModel: ObservableObject {

    @Published var selectedDate: Date
    @Published private(set) var days: [Date] = []
    @Published private(set) var availability: [Date: Bool] = [:]

    private let calendar: Calendar

    init(
        calendar: Calendar = .current,
        initialSelected: Date = Date(),
        daysAfter: Int = 30
    ) {
        self.calendar = calendar
        let today = calendar.startOfDay(for: initialSelected)
        self.selectedDate = today
        buildDays(startingAt: today, daysAfter: daysAfter)
        setAvailability { _ in true }
    }

    var selectedUnixTimestamp: Int {
        Int(calendar.startOfDay(for: selectedDate).timeIntervalSince1970)
    }

    func forceSelect(_ date: Date) {
        selectedDate = calendar.startOfDay(for: date)
    }

    private func buildDays(startingAt start: Date, daysAfter: Int) {
        let startDay = calendar.startOfDay(for: start)
        let end = calendar.date(byAdding: .day, value: daysAfter, to: startDay) ?? startDay

        var result: [Date] = []
        var d = startDay
        while d <= end {
            result.append(d)
            d = calendar.date(byAdding: .day, value: 1, to: d) ?? d
        }

        days = result
    }

    func setAvailability(using rule: (Date) -> Bool) {
        var map: [Date: Bool] = [:]
        for day in days {
            map[calendar.startOfDay(for: day)] = rule(day)
        }
        availability = map

        let key = calendar.startOfDay(for: selectedDate)
        if !(availability[key] ?? true) {
            if let next = days.first(where: { availability[calendar.startOfDay(for: $0)] ?? true }) {
                selectedDate = next
            }
        }
    }

    func isAvailable(_ date: Date) -> Bool {
        availability[calendar.startOfDay(for: date)] ?? true
    }

    func select(_ date: Date) {
        let day = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: Date())
        guard day >= today, isAvailable(day) else { return }
        selectedDate = day
    }

    func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }

    func weekdayText(for date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "EEE"
        return f.string(from: date)
    }

    func dayNumber(for date: Date) -> String {
        String(calendar.component(.day, from: date))
    }
}
