import Foundation

enum MockData {
    // MARK: - Current User

    static let currentUser = LocalUser(
        id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
        appleId: "mock.apple.id",
        email: "sarah.johnson@email.com",
        displayName: "Sarah Johnson"
    )

    static let currentUserFamilyMembers: [LocalFamilyMember] = [
        LocalFamilyMember(
            id: UUID(uuidString: "21111111-1111-1111-1111-111111111111")!,
            name: "Tommy"
        ),
        LocalFamilyMember(
            id: UUID(uuidString: "21111111-1111-1111-1111-111111111112")!,
            name: "Emma"
        )
    ]

    // MARK: - Other Users

    static let coachDan = LocalUser(
        id: UUID(uuidString: "11111111-1111-1111-1111-111111111112")!,
        appleId: "coach.dan.apple.id",
        email: "coach.dan@email.com",
        displayName: "Coach Dan"
    )

    static let mikeJohnson = LocalUser(
        id: UUID(uuidString: "11111111-1111-1111-1111-111111111113")!,
        appleId: "mike.johnson.apple.id",
        email: "mike.johnson@email.com",
        displayName: "Mike Johnson"
    )

    static let lisaMiller = LocalUser(
        id: UUID(uuidString: "11111111-1111-1111-1111-111111111114")!,
        appleId: "lisa.miller.apple.id",
        email: "lisa.miller@email.com",
        displayName: "Lisa Miller"
    )

    // MARK: - Communities

    static let communities: [LocalCommunity] = [
        LocalCommunity(
            id: UUID(uuidString: "31111111-1111-1111-1111-111111111111")!,
            name: "Johnson Family",
            communityType: .family,
            memberCount: 4,
            settings: CommunitySettings.defaultSettings(for: .family)
        ),
        LocalCommunity(
            id: UUID(uuidString: "31111111-1111-1111-1111-111111111112")!,
            name: "Tigers Little League",
            communityType: .team,
            memberCount: 12,
            settings: CommunitySettings.defaultSettings(for: .team)
        ),
        LocalCommunity(
            id: UUID(uuidString: "31111111-1111-1111-1111-111111111113")!,
            name: "Book Club",
            communityType: .club,
            memberCount: 8,
            settings: CommunitySettings.defaultSettings(for: .club)
        )
    ]

    static var currentCommunity: LocalCommunity { communities[1] }

    // MARK: - Events

    static let events: [LocalEvent] = {
        let calendar = Calendar.current
        let now = Date()

        return [
            LocalEvent(
                id: UUID(uuidString: "41111111-1111-1111-1111-111111111111")!,
                title: "Practice",
                descriptionText: "Bring cleats and water bottle. We'll be working on batting practice.",
                startsAt: calendar.date(byAdding: .day, value: 3, to: now)!,
                endsAt: calendar.date(byAdding: .hour, value: 1, to: calendar.date(byAdding: .day, value: 3, to: now)!)!,
                locationName: "Lincoln Park Field #3",
                locationAddress: "123 Park Ave",
                category: .practice,
                createdById: coachDan.id,
                createdByName: coachDan.displayName
            ),
            LocalEvent(
                id: UUID(uuidString: "41111111-1111-1111-1111-111111111112")!,
                title: "Game vs Eagles",
                descriptionText: "First game of the season! Arrive 30 minutes early for warm-up.",
                startsAt: calendar.date(byAdding: .day, value: 7, to: now)!,
                endsAt: calendar.date(byAdding: .hour, value: 2, to: calendar.date(byAdding: .day, value: 7, to: now)!)!,
                locationName: "Central Stadium",
                locationAddress: "456 Stadium Blvd",
                category: .game,
                createdById: coachDan.id,
                createdByName: coachDan.displayName
            ),
            LocalEvent(
                id: UUID(uuidString: "41111111-1111-1111-1111-111111111113")!,
                title: "Team Meeting",
                descriptionText: "Season planning and parent meeting. Please attend!",
                startsAt: calendar.date(byAdding: .day, value: 1, to: now)!,
                endsAt: calendar.date(byAdding: .hour, value: 1, to: calendar.date(byAdding: .day, value: 1, to: now)!)!,
                locationName: "Community Center Room B",
                locationAddress: "789 Main Street",
                category: .meeting,
                createdById: coachDan.id,
                createdByName: coachDan.displayName
            ),
            LocalEvent(
                id: UUID(uuidString: "41111111-1111-1111-1111-111111111114")!,
                title: "End of Season Party",
                descriptionText: "Pizza and awards ceremony! Families welcome.",
                startsAt: calendar.date(byAdding: .month, value: 2, to: now)!,
                allDay: true,
                locationName: "Coach Dan's House",
                locationAddress: "321 Oak Lane",
                category: .social,
                createdById: coachDan.id,
                createdByName: coachDan.displayName
            )
        ]
    }()

    static var eventsWithRSVPs: [LocalEvent] {
        let eventsWithRSVPs = events

        // Add RSVPs to first event
        eventsWithRSVPs[0].rsvps = [
            LocalRSVP(status: .yes, userId: currentUser.id, userName: currentUser.displayName),
            LocalRSVP(status: .yes, userId: coachDan.id, userName: coachDan.displayName),
            LocalRSVP(status: .yes, userId: mikeJohnson.id, userName: mikeJohnson.displayName),
            LocalRSVP(status: .maybe, userId: lisaMiller.id, userName: lisaMiller.displayName),
            LocalRSVP(
                status: .yes,
                userId: currentUser.id,
                userName: currentUser.displayName,
                familyMemberId: currentUserFamilyMembers[0].id,
                familyMemberName: currentUserFamilyMembers[0].name
            )
        ]

        return eventsWithRSVPs
    }

    // MARK: - Posts

    static let posts: [LocalPost] = {
        let now = Date()
        let calendar = Calendar.current

        return [
            LocalPost(
                id: UUID(uuidString: "51111111-1111-1111-1111-111111111111")!,
                type: .announcement,
                content: "Season starts March 1! Make sure dues are paid by Feb 15. Looking forward to a great season!",
                isPinned: true,
                isAnnouncement: true,
                reactionCounts: ["like": 8, "celebrate": 4],
                commentCount: 3,
                createdAt: calendar.date(byAdding: .day, value: -2, to: now)!,
                authorId: coachDan.id,
                authorName: coachDan.displayName
            ),
            LocalPost(
                id: UUID(uuidString: "51111111-1111-1111-1111-111111111112")!,
                type: .photo,
                content: "Great practice today! Tommy is really improving his swing.",
                mediaUrls: ["https://example.com/photo1.jpg"],
                reactionCounts: ["like": 5, "love": 2],
                commentCount: 2,
                createdAt: calendar.date(byAdding: .hour, value: -1, to: now)!,
                authorId: currentUser.id,
                authorName: currentUser.displayName
            ),
            LocalPost(
                id: UUID(uuidString: "51111111-1111-1111-1111-111111111113")!,
                type: .poll,
                content: "What day works best for the team party?",
                pollData: PollData(
                    question: "What day works best for the team party?",
                    options: ["Saturday, Feb 1", "Sunday, Feb 2", "Saturday, Feb 8"],
                    allowMultiple: false,
                    votes: [
                        currentUser.id: [0],
                        mikeJohnson.id: [0],
                        lisaMiller.id: [2],
                        coachDan.id: [0]
                    ]
                ),
                reactionCounts: [:],
                commentCount: 1,
                createdAt: calendar.date(byAdding: .hour, value: -3, to: now)!,
                authorId: coachDan.id,
                authorName: coachDan.displayName
            ),
            LocalPost(
                id: UUID(uuidString: "51111111-1111-1111-1111-111111111114")!,
                type: .eventShare,
                content: "New event: Practice on Saturday",
                linkedEventId: events[0].id,
                reactionCounts: ["like": 2],
                commentCount: 0,
                createdAt: calendar.date(byAdding: .hour, value: -5, to: now)!,
                authorId: coachDan.id,
                authorName: coachDan.displayName
            ),
            LocalPost(
                id: UUID(uuidString: "51111111-1111-1111-1111-111111111115")!,
                type: .text,
                content: "Thanks everyone for helping clean up after yesterday's game! You all rock! 🎉",
                reactionCounts: ["like": 6, "celebrate": 3],
                commentCount: 4,
                createdAt: calendar.date(byAdding: .day, value: -1, to: now)!,
                authorId: lisaMiller.id,
                authorName: lisaMiller.displayName
            )
        ]
    }()

    static var postsWithComments: [LocalPost] {
        let postsWithComments = posts

        postsWithComments[1].comments = [
            LocalComment(
                content: "He's looking great! Keep it up.",
                authorId: coachDan.id,
                authorName: coachDan.displayName,
                createdAt: Date().addingTimeInterval(-2700)
            ),
            LocalComment(
                content: "So proud of him! 🎉",
                authorId: mikeJohnson.id,
                authorName: mikeJohnson.displayName,
                createdAt: Date().addingTimeInterval(-1800)
            )
        ]

        return postsWithComments
    }

    // MARK: - Transactions

    static let transactions: [LocalTransaction] = {
        let now = Date()
        let calendar = Calendar.current

        return [
            LocalTransaction(
                id: UUID(uuidString: "61111111-1111-1111-1111-111111111111")!,
                type: .expense,
                descriptionText: "Snacks for practice",
                totalAmount: 3200, // $32.00
                paidById: coachDan.id,
                paidByName: coachDan.displayName,
                category: .food,
                transactionDate: calendar.date(byAdding: .day, value: -1, to: now)!
            ),
            LocalTransaction(
                id: UUID(uuidString: "61111111-1111-1111-1111-111111111112")!,
                type: .expense,
                descriptionText: "Equipment bags",
                totalAmount: 15600, // $156.00
                paidById: currentUser.id,
                paidByName: currentUser.displayName,
                category: .equipment,
                transactionDate: calendar.date(byAdding: .day, value: -3, to: now)!
            ),
            LocalTransaction(
                id: UUID(uuidString: "61111111-1111-1111-1111-111111111113")!,
                type: .expense,
                descriptionText: "Gas for away game",
                totalAmount: 4500, // $45.00
                paidById: mikeJohnson.id,
                paidByName: mikeJohnson.displayName,
                category: .travel,
                transactionDate: calendar.date(byAdding: .day, value: -5, to: now)!
            )
        ]
    }()

    static var transactionsWithSplits: [LocalTransaction] {
        let transactionsWithSplits = transactions

        transactionsWithSplits[0].splits = [
            LocalSplit(userId: currentUser.id, userName: currentUser.displayName, amount: 267),
            LocalSplit(userId: mikeJohnson.id, userName: mikeJohnson.displayName, amount: 267),
            LocalSplit(userId: lisaMiller.id, userName: lisaMiller.displayName, amount: 267)
        ]

        transactionsWithSplits[1].splits = [
            LocalSplit(userId: coachDan.id, userName: coachDan.displayName, amount: 1300),
            LocalSplit(userId: mikeJohnson.id, userName: mikeJohnson.displayName, amount: 1300),
            LocalSplit(userId: lisaMiller.id, userName: lisaMiller.displayName, amount: 1300)
        ]

        return transactionsWithSplits
    }

    // MARK: - Members

    static let members: [(user: LocalUser, role: MemberRole)] = [
        (coachDan, .admin),
        (currentUser, .admin),
        (mikeJohnson, .member),
        (lisaMiller, .member)
    ]
}
