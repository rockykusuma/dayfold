import SwiftUI

extension View {
    /// iPad: a centred column, so rows and their trailing details don't stretch across a 13" screen.
    /// iPhone is narrower than the column already; Mac keeps the full window width.
    /// Put it before `.background(Color.paper)` so the paper still fills the screen.
    func readableColumn(_ width: CGFloat = 720) -> some View {
        #if os(iOS)
        frame(maxWidth: width).frame(maxWidth: .infinity)
        #else
        self
        #endif
    }
}
