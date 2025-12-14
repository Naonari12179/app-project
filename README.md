# WatchFeeds

SwiftUI iOS 17+ app that aggregates RSS feeds, website change monitoring, and keyword topics. Data persists via SwiftData and background refresh hooks.

## Structure
- `WatchFeedsApp.swift`: App entry and SwiftData container setup.
- `Models/`: SwiftData models and DTOs for API-friendly serialization.
- `Services/`: RSS parsing and watch refresh logic (RSS + website hashing + topic placeholder).
- `Store/`: Data access helpers for watches and feed items.
- `Views/`: SwiftUI screens for home feed, watchlist, details, and saved items.
- `Background/`: Minimal BGAppRefresh task handler.
- `Tests/`: RSS parsing unit test.

## Building
Open the project in Xcode 15+ with iOS 17 SDK. Ensure Background Modes > Background fetch is enabled for BGTask scheduling.
