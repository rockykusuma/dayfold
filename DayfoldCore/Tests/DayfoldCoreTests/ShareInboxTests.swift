import Foundation
import Testing
@testable import DayfoldCore

@Suite("Share inbox")
struct ShareInboxTests {
    private let dir = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)

    @Test func composeJoinsTextAndLink() {
        let url = URL(string: "https://example.com/a")!
        #expect(ShareInbox.compose(text: " Read this \n", url: url) == "Read this https://example.com/a")
        #expect(ShareInbox.compose(text: "", url: url) == "https://example.com/a")
        #expect(ShareInbox.compose(text: "see https://example.com/a", url: url) == "see https://example.com/a")
        #expect(ShareInbox.compose(text: "Just text", url: nil) == "Just text")
        #expect(ShareInbox.compose(text: "  ", url: nil) == nil)
    }

    @Test func drainsOldestFirstAndEmpties() throws {
        try ShareInbox.add("second", in: dir, now: Date(timeIntervalSince1970: 200))
        try ShareInbox.add("first", in: dir, now: Date(timeIntervalSince1970: 100))
        var got: [String] = []
        ShareInbox.drain(dir) { got.append($0) }
        #expect(got == ["first", "second"])
        ShareInbox.drain(dir) { got.append($0) }
        #expect(got.count == 2)
    }

    @Test func aFailedAddKeepsItAndTheRest() throws {
        struct SaveFailed: Error {}
        try ShareInbox.add("a", in: dir, now: Date(timeIntervalSince1970: 1))
        try ShareInbox.add("b", in: dir, now: Date(timeIntervalSince1970: 2))
        ShareInbox.drain(dir) { _ in throw SaveFailed() }
        var got: [String] = []
        ShareInbox.drain(dir) { got.append($0) }
        #expect(got == ["a", "b"])
    }

    @Test func missingInboxIsEmpty() {
        var called = false
        ShareInbox.drain(dir) { _ in called = true }
        #expect(!called)
    }
}
