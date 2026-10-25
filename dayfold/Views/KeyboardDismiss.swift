import SwiftUI

extension View {
    /// iPhone: a "hide keyboard" button on the bar above the keyboard, for any focused field in this sheet.
    /// Add once per sheet with text fields; capture-bar screens use the bar's own button instead. No-op on Mac.
    func keyboardDismissButton() -> some View {
        #if os(iOS)
        toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(action: hideKeyboard) {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
                .accessibilityLabel("Hide keyboard")
            }
        }
        #else
        self
        #endif
    }
}

#if os(iOS)
/// Resigns whichever field has focus, wherever it is.
func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
#endif
