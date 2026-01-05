import SwiftUI

struct RSVPButton: View {
    let status: RSVPStatus
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.xs) {
                Image(systemName: status.icon)
                    .font(.title2)

                Text(status.displayName)
                    .font(Theme.Typography.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.md)
            .background(isSelected ? statusColor.opacity(0.2) : Theme.Colors.tertiaryBackground)
            .foregroundStyle(isSelected ? statusColor : .secondary)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .stroke(isSelected ? statusColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var statusColor: Color {
        switch status {
        case .yes: return Theme.Colors.going
        case .no: return Theme.Colors.notGoing
        case .maybe: return Theme.Colors.maybe
        }
    }
}

struct RSVPButtonGroup: View {
    @Binding var selectedStatus: RSVPStatus?
    let onSelect: (RSVPStatus) -> Void

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            ForEach(RSVPStatus.allCases, id: \.self) { status in
                RSVPButton(
                    status: status,
                    isSelected: selectedStatus == status
                ) {
                    selectedStatus = status
                    onSelect(status)
                }
            }
        }
    }
}

#Preview("RSVP Buttons") {
    VStack(spacing: 20) {
        HStack {
            RSVPButton(status: .yes, isSelected: true) { }
            RSVPButton(status: .no, isSelected: false) { }
            RSVPButton(status: .maybe, isSelected: false) { }
        }
        .padding()
    }
}
