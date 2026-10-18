import Foundation
import Observation

/// Lets any row ask for the Search screen with a query (e.g. a tapped tag).
/// `RootView` switches to Search when `shown` changes.
@Observable
final class SearchRouter {
    static let shared = SearchRouter()

    var query = ""
    private(set) var shown = 0

    func show(_ query: String) {
        self.query = query
        shown += 1
    }
}
