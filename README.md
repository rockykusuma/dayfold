# Dayfold

A daily log for people who get asked for things all day.

Capture every request the moment it lands, timestamped on today's page. Each evening,
Dayfold walks you through what's still open — done, still going, push to a date, or drop —
and folds the rest into tomorrow. Nothing is forgotten until you decide it's finished.

- **Mac + iPhone**, synced via iCloud (SwiftData + CloudKit). No accounts, no server.
- **Work / Personal** in one place — a filter, not two apps.
- **Journal** entries live alongside tasks and never expire.
- **Markdown export** of every day, so your data outlives the app.

Open source under the MIT licence.

## Status

Pre-alpha. Building v0.1: day page, timestamped capture, done/rollover, evening Review, sync.

## Requirements

Xcode 26, iOS 17 / macOS 14.

## Project layout

```
dayfold/            SwiftUI app target (iOS + macOS)
DayfoldCore/        Swift package: model, rollover + review rules, tests (no UI)
docs/               Spec and decisions
```
