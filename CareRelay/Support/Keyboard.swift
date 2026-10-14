import SwiftUI
import UIKit

func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

private struct DismissableKeyboardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollDismissesKeyboard(.interactively)
    }
}

extension View {
    func dismissableKeyboard() -> some View {
        modifier(DismissableKeyboardModifier())
    }
}
