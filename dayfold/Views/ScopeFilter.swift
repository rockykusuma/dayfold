import SwiftUI
import DayfoldCore

/// Work / Personal / Both. One store, one toggle.
enum ScopeFilter: String, CaseIterable, Identifiable {
    case all, work, personal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: "Both"
        case .work: "Work"
        case .personal: "Personal"
        }
    }

    func includes(_ scope: EntryScope) -> Bool {
        switch self {
        case .all: true
        case .work: scope == .work
        case .personal: scope == .personal
        }
    }

    /// Scope a new entry should get when captured under this filter.
    var defaultScope: EntryScope? {
        switch self {
        case .all: nil
        case .work: .work
        case .personal: .personal
        }
    }
}
