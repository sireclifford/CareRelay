import SwiftUI

enum AppColor {
    /// Primary brand accent — calm, muted blue-teal. Used for buttons, links, active states.
    static let accent = Color(red: 0.13, green: 0.47, blue: 0.53)

    /// Reserved for open Alerts only. Keeping red exclusive to this one meaning
    /// is what makes it actually grab attention when it shows up.
    static let alertOpen = Color.red

    static let resolved = Color.green
}

enum AppSpacing {
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
}
