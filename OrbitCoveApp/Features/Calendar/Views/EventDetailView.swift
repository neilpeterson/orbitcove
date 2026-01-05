import SwiftUI

struct EventDetailView: View {
    let event: LocalEvent
    @State private var selectedRSVP: RSVPStatus?
    @State private var showFamilyRSVP = false
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                // Header
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    HStack {
                        CategoryBadge(category: event.category)
                        Spacer()
                    }

                    Text(event.title)
                        .font(Theme.Typography.title)
                        .fontWeight(.bold)
                }

                Divider()

                // Details
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // Date & Time
                    DetailRow(icon: "calendar", title: "Date & Time") {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                            Text(event.startsAt.fullDateString)
                                .font(Theme.Typography.body)

                            if event.allDay {
                                Text("All Day")
                                    .font(Theme.Typography.subheadline)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text(event.startsAt.eventTimeRangeDisplay(endDate: event.endsAt))
                                    .font(Theme.Typography.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    // Location
                    if let locationName = event.locationName {
                        DetailRow(icon: "mappin.circle", title: "Location") {
                            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                Text(locationName)
                                    .font(Theme.Typography.body)

                                if let address = event.locationAddress {
                                    Text(address)
                                        .font(Theme.Typography.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Button("Open in Maps") {
                                    openMaps()
                                }
                                .font(Theme.Typography.subheadline)
                            }
                        }
                    }

                    // Description
                    if let description = event.descriptionText {
                        DetailRow(icon: "text.alignleft", title: "Description") {
                            Text(description)
                                .font(Theme.Typography.body)
                        }
                    }

                    // Created by
                    DetailRow(icon: "person", title: "Created by") {
                        Text(event.createdByName)
                            .font(Theme.Typography.body)
                    }
                }

                Divider()

                // RSVP Section
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    Text("Your Response")
                        .font(Theme.Typography.headline)

                    RSVPButtonGroup(selectedStatus: $selectedRSVP) { status in
                        // Handle RSVP
                    }

                    Button {
                        showFamilyRSVP = true
                    } label: {
                        Label("Add family member response", systemImage: "plus.circle")
                            .font(Theme.Typography.subheadline)
                    }
                }

                Divider()

                // Attendees Section
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    Text("Who's Coming (\(event.rsvps.count))")
                        .font(Theme.Typography.headline)

                    RSVPList(rsvps: event.rsvps)
                }

                // Add to Calendar button
                Button {
                    // Add to calendar
                } label: {
                    Label("Add to Calendar", systemImage: "calendar.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.secondary)
                .padding(.top, Theme.Spacing.lg)
            }
            .padding(Theme.Spacing.lg)
        }
        .navigationTitle("Event")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showFamilyRSVP) {
            FamilyRSVPSheet(event: event)
        }
    }

    private func openMaps() {
        if let lat = event.locationLat, let lng = event.locationLng {
            let url = URL(string: "maps://?ll=\(lat),\(lng)")!
            openURL(url)
        } else if let name = event.locationName?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let url = URL(string: "maps://?q=\(name)")!
            openURL(url)
        }
    }
}

struct CategoryBadge: View {
    let category: EventCategory

    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            Image(systemName: category.icon)
            Text(category.displayName)
        }
        .font(Theme.Typography.caption)
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, Theme.Spacing.xs)
        .background(categoryColor.opacity(0.2))
        .foregroundStyle(categoryColor)
        .clipShape(Capsule())
    }

    private var categoryColor: Color {
        switch category {
        case .practice: return Theme.Colors.practice
        case .game: return Theme.Colors.game
        case .meeting: return Theme.Colors.meeting
        case .social: return Theme.Colors.social
        case .other: return .gray
        }
    }
}

struct DetailRow<Content: View>: View {
    let icon: String
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Theme.Colors.primary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(title)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)

                content
            }
        }
    }
}

struct RSVPList: View {
    let rsvps: [LocalRSVP]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Going
            let going = rsvps.filter { $0.status == .yes }
            if !going.isEmpty {
                RSVPSection(
                    title: "Going (\(going.count))",
                    color: Theme.Colors.going,
                    names: going.map { $0.displayName }
                )
            }

            // Maybe
            let maybe = rsvps.filter { $0.status == .maybe }
            if !maybe.isEmpty {
                RSVPSection(
                    title: "Maybe (\(maybe.count))",
                    color: Theme.Colors.maybe,
                    names: maybe.map { $0.displayName }
                )
            }

            // Not Going
            let notGoing = rsvps.filter { $0.status == .no }
            if !notGoing.isEmpty {
                RSVPSection(
                    title: "Not Going (\(notGoing.count))",
                    color: Theme.Colors.notGoing,
                    names: notGoing.map { $0.displayName }
                )
            }
        }
    }
}

struct RSVPSection: View {
    let title: String
    let color: Color
    let names: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            HStack(spacing: Theme.Spacing.xs) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)

                Text(title)
                    .font(Theme.Typography.subheadline)
                    .fontWeight(.medium)
            }

            Text(names.joined(separator: ", "))
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.secondary)
                .padding(.leading, Theme.Spacing.lg)
        }
    }
}

struct FamilyRSVPSheet: View {
    let event: LocalEvent
    @Environment(\.dismiss) private var dismiss
    @State private var familyRSVPs: [UUID: RSVPStatus] = [:]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(MockData.currentUserFamilyMembers, id: \.id) { member in
                        FamilyMemberRSVPRow(
                            member: member,
                            selectedStatus: Binding(
                                get: { familyRSVPs[member.id] },
                                set: { familyRSVPs[member.id] = $0 }
                            )
                        )
                    }
                } header: {
                    Text("Who's going to this event?")
                }
            }
            .navigationTitle("RSVP for Family")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { dismiss() }
                }
            }
        }
    }
}

struct FamilyMemberRSVPRow: View {
    let member: LocalFamilyMember
    @Binding var selectedStatus: RSVPStatus?

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                AvatarView(name: member.name, size: 32)
                Text(member.name)
                    .font(Theme.Typography.headline)
            }

            HStack(spacing: Theme.Spacing.sm) {
                ForEach(RSVPStatus.allCases, id: \.self) { status in
                    Button {
                        selectedStatus = status
                    } label: {
                        Text(status.displayName)
                            .font(Theme.Typography.caption)
                            .padding(.horizontal, Theme.Spacing.sm)
                            .padding(.vertical, Theme.Spacing.xs)
                            .background(selectedStatus == status ? statusColor(for: status).opacity(0.2) : Theme.Colors.tertiaryBackground)
                            .foregroundStyle(selectedStatus == status ? statusColor(for: status) : .secondary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, Theme.Spacing.xs)
    }

    private func statusColor(for status: RSVPStatus) -> Color {
        switch status {
        case .yes: return Theme.Colors.going
        case .no: return Theme.Colors.notGoing
        case .maybe: return Theme.Colors.maybe
        }
    }
}

#Preview {
    NavigationStack {
        EventDetailView(event: MockData.eventsWithRSVPs[0])
    }
}
