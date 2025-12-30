import Foundation
import Combine

final class CalendarStripViewModel: ObservableObject {
    @Published var selectedDate: Date
    @Published private(set) var days: [Date] = []
    // Availability per day (true = available, false = unavailable)
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
        // By default, mark all generated days available
        setAvailability { _ in true }
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

    // Provide availability via a rule closure
    func setAvailability(using rule: (Date) -> Bool) {
        var map: [Date: Bool] = [:]
        for day in days {
            map[calendar.startOfDay(for: day)] = rule(day)
        }
        availability = map

        // If currently selected day becomes unavailable, move selection to the next available day
        if !(availability[calendar.startOfDay(for: selectedDate)] ?? true) {
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
        // Prevent selecting past dates and unavailable dates
        guard day >= today, isAvailable(day) else { return }
        selectedDate = day
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
