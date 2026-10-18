#if os(macOS)
import SwiftUI
import SwiftData
import DayfoldCore

/// Menu-bar panel: capture without switching apps. Same CaptureBar (and parser) as the main window.
struct MenuBarCapture: View {
    @Query(sort: \Entry.createdAt) private var entries: [Entry]
    @FocusState private var focused: Bool
    @Environment(\.openWindow) private var openWindow

    private var today: Date { Calendar.current.startOfDay(for: Date()) }
    private var openCount: Int { Review.pending(entries, on: today).count }
    /// Last few things captured today, newest first: confirmation that Enter worked.
    private var recent: [Entry] {
        entries.filter { Calendar.current.isDateInToday($0.createdAt) }.suffix(3).reversed()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(Date(), format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.system(.headline, design: .serif))
                Spacer()
                Text("\(openCount) open")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            CaptureBar(filter: .all, day: Date(), focus: $focused)

            if !recent.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(recent) { entry in
                        EntryRow(entry: entry, day: today) {
                            withAnimation(.snappy) {
                                entry.status.isActive ? Review.apply(.done, to: entry) : Review.reopen(entry)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 4)
                        .padding(.trailing, 16)
                    }
                }
                .padding(.vertical, 4)
            }

            Divider()

            HStack {
                Button("Open Dayfold") { showMainWindow() }
                    .keyboardShortcut("o", modifiers: .command)
                Spacer()
                Button("Quit") { NSApp.terminate(nil) }
                    .keyboardShortcut("q", modifiers: .command)
            }
            .buttonStyle(.borderless)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .frame(width: 380)
        .background(Color.paper)
        .task { focused = true }
    }

    /// Bring the existing day-page window forward; open one only if it was closed.
    private func showMainWindow() {
        NSApp.activate()
        if let window = NSApp.windows.first(where: { $0.canBecomeMain }) {
            window.makeKeyAndOrderFront(nil)
        } else {
            openWindow(id: "main")
        }
    }
}
#endif
