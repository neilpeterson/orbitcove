import SwiftUI

extension View {
    // MARK: - Conditional Modifier

    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    // MARK: - Hide Keyboard

    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    // MARK: - Read Size

    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// MARK: - Navigation Title with Large Title

struct NavigationTitleModifier: ViewModifier {
    let title: String
    let displayMode: NavigationBarItem.TitleDisplayMode

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(displayMode)
    }
}

extension View {
    func navigationTitle(_ title: String, displayMode: NavigationBarItem.TitleDisplayMode) -> some View {
        modifier(NavigationTitleModifier(title: title, displayMode: displayMode))
    }
}
