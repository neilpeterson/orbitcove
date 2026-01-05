import SwiftUI

@Observable
final class CalendarViewModel {
    var events: [LocalEvent] = []
    var currentMonth = Date()
    var selectedDate: Date?
    var isLoading = false
    var error: Error?

    var filteredEvents: [LocalEvent] {
        if let selectedDate {
            return events.filter { $0.startsAt.isSameDay(as: selectedDate) }
        }
        return events.filter { $0.startsAt >= Date() }
            .sorted { $0.startsAt < $1.startsAt }
    }

    func eventsForDate(_ date: Date) -> [LocalEvent] {
        events.filter { $0.startsAt.isSameDay(as: date) }
    }

    func loadEvents() async {
        isLoading = true
        error = nil

        do {
            try await Task.sleep(for: .milliseconds(500))
            events = MockData.eventsWithRSVPs
        } catch {
            self.error = error
        }

        isLoading = false
    }

    func previousMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    func nextMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
}
