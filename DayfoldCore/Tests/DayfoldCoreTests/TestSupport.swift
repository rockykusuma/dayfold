import Foundation

/// Gregorian, Asia/Kolkata (no DST). 2026-10-19 is a Monday.
let ist: Calendar = {
    var c = Calendar(identifier: .gregorian)
    c.timeZone = TimeZone(identifier: "Asia/Kolkata")!
    return c
}()

func at(_ y: Int, _ m: Int, _ d: Int, _ h: Int = 0) -> Date {
    ist.date(from: DateComponents(year: y, month: m, day: d, hour: h))!
}
