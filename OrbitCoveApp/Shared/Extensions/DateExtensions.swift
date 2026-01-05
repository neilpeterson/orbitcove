import Foundation

extension Date {
    // MARK: - Relative Time Display

    var relativeTimeString: String {
        let now = Date()
        let components = Calendar.current.dateComponents(
            [.minute, .hour, .day, .weekOfYear, .month, .year],
            from: self,
            to: now
        )

        if let years = components.year, years > 0 {
            return formatted(.dateTime.month().day().year())
        }

        if let months = components.month, months > 0 {
            return formatted(.dateTime.month().day())
        }

        if let weeks = components.weekOfYear, weeks > 0 {
            if weeks == 1 {
                return "Last week"
            }
            return formatted(.dateTime.month().day())
        }

        if let days = components.day, days > 0 {
            if days == 1 {
                return "Yesterday"
            }
            return "\(days) days ago"
        }

        if let hours = components.hour, hours > 0 {
            return "\(hours)h ago"
        }

        if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m ago"
        }

        return "Just now"
    }

    // MARK: - Formatted Strings

    var shortDateString: String {
        formatted(.dateTime.month(.abbreviated).day())
    }

    var shortDayOfWeek: String {
        formatted(.dateTime.weekday(.abbreviated))
    }

    var fullDateString: String {
        formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    var timeString: String {
        formatted(.dateTime.hour().minute())
    }

    var dateTimeString: String {
        formatted(.dateTime.month(.abbreviated).day().hour().minute())
    }

    // MARK: - Calendar Helpers

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }

    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }

    var endOfMonth: Date {
        Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
    }

    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }

    // MARK: - Event Display

    var eventDateDisplay: String {
        if isToday {
            return "Today, \(formatted(.dateTime.month(.abbreviated).day()))"
        } else if isTomorrow {
            return "Tomorrow, \(formatted(.dateTime.month(.abbreviated).day()))"
        } else {
            return formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
        }
    }

    func eventTimeRangeDisplay(endDate: Date?) -> String {
        if let endDate {
            return "\(timeString) - \(endDate.timeString)"
        }
        return timeString
    }
}

extension DateFormatter {
    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
}
