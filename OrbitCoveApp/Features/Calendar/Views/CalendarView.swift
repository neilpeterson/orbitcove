import SwiftUI

struct CalendarView: View {
    @State private var viewModel = CalendarViewModel()
    @State private var showCreateEvent = false

    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.events.isEmpty {
                LoadingView(message: "Loading events...")
            } else if viewModel.events.isEmpty {
                EmptyStateView.noEvents {
                    showCreateEvent = true
                }
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        // Month header
                        CalendarMonthHeader(
                            currentMonth: viewModel.currentMonth,
                            onPrevious: { viewModel.previousMonth() },
                            onNext: { viewModel.nextMonth() }
                        )

                        // Calendar grid
                        CalendarGridView(
                            currentMonth: viewModel.currentMonth,
                            selectedDate: $viewModel.selectedDate,
                            eventsForDate: viewModel.eventsForDate
                        )

                        Divider()
                            .padding(.vertical, Theme.Spacing.md)

                        // Events list
                        EventsListView(
                            events: viewModel.filteredEvents,
                            selectedDate: viewModel.selectedDate
                        )
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                }
                .refreshable {
                    await viewModel.loadEvents()
                }
            }

            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showCreateEvent = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(Theme.Colors.primary)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(Theme.Spacing.lg)
                }
            }
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCreateEvent) {
            NavigationStack {
                CreateEventView()
            }
        }
        .task {
            await viewModel.loadEvents()
        }
    }
}

struct CalendarMonthHeader: View {
    let currentMonth: Date
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.title3)
            }

            Spacer()

            Text(DateFormatter.monthYear.string(from: currentMonth))
                .font(Theme.Typography.title3)
                .fontWeight(.semibold)

            Spacer()

            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.title3)
            }
        }
        .padding(.vertical, Theme.Spacing.md)
    }
}

struct CalendarGridView: View {
    let currentMonth: Date
    @Binding var selectedDate: Date?
    let eventsForDate: (Date) -> [LocalEvent]

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            // Weekday headers
            LazyVGrid(columns: columns, spacing: Theme.Spacing.sm) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Days grid
            LazyVGrid(columns: columns, spacing: Theme.Spacing.sm) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date {
                        CalendarDayCell(
                            date: date,
                            isSelected: selectedDate?.isSameDay(as: date) ?? false,
                            isToday: date.isToday,
                            hasEvents: !eventsForDate(date).isEmpty
                        ) {
                            selectedDate = date
                        }
                    } else {
                        Text("")
                            .frame(height: 40)
                    }
                }
            }
        }
    }

    private var daysInMonth: [Date?] {
        let calendar = Calendar.current
        let startOfMonth = currentMonth.startOfMonth

        guard let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let leadingEmptyDays = firstWeekday - 1

        var days: [Date?] = Array(repeating: nil, count: leadingEmptyDays)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }

        return days
    }
}

struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasEvents: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.xxs) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(Theme.Typography.body)
                    .foregroundStyle(foregroundColor)

                if hasEvents {
                    Circle()
                        .fill(Theme.Colors.primary)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(width: 40, height: 40)
            .background(backgroundColor)
            .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private var backgroundColor: Color {
        if isSelected {
            return Theme.Colors.primary
        } else if isToday {
            return Theme.Colors.primary.opacity(0.2)
        }
        return .clear
    }

    private var foregroundColor: Color {
        if isSelected {
            return .white
        }
        return .primary
    }
}

struct EventsListView: View {
    let events: [LocalEvent]
    let selectedDate: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(headerText)
                .font(Theme.Typography.headline)

            if events.isEmpty {
                Text("No events")
                    .font(Theme.Typography.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, Theme.Spacing.lg)
            } else {
                ForEach(events, id: \.id) { event in
                    NavigationLink {
                        EventDetailView(event: event)
                    } label: {
                        EventCard(event: event)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var headerText: String {
        if let date = selectedDate {
            return date.eventDateDisplay
        }
        return "Upcoming Events"
    }
}

struct EventCard: View {
    let event: LocalEvent

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Category indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(categoryColor)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                HStack {
                    if event.allDay {
                        Text("All Day")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(categoryColor)
                    } else {
                        Text(event.startsAt.timeString)
                            .font(Theme.Typography.caption)
                            .foregroundStyle(categoryColor)
                    }
                }

                Text(event.title)
                    .font(Theme.Typography.headline)

                if let location = event.locationName {
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "mappin")
                            .font(.caption)
                        Text(location)
                            .font(Theme.Typography.caption)
                    }
                    .foregroundStyle(.secondary)
                }

                if event.goingCount > 0 || event.maybeCount > 0 {
                    HStack(spacing: Theme.Spacing.sm) {
                        if event.goingCount > 0 {
                            Label("\(event.goingCount) Going", systemImage: "checkmark.circle")
                                .font(Theme.Typography.caption)
                        }
                        if event.maybeCount > 0 {
                            Label("\(event.maybeCount) Maybe", systemImage: "questionmark.circle")
                                .font(Theme.Typography.caption)
                        }
                    }
                    .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg))
    }

    private var categoryColor: Color {
        switch event.category {
        case .practice: return Theme.Colors.practice
        case .game: return Theme.Colors.game
        case .meeting: return Theme.Colors.meeting
        case .social: return Theme.Colors.social
        case .other: return .gray
        }
    }
}

#Preview {
    NavigationStack {
        CalendarView()
    }
    .environment(AppState())
}
