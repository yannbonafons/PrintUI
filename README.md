# PrintUI

A lightweight, extensible logging library for Swift. Route logs to multiple destinations (console, remote services, analytics …) through a simple provider-based architecture.

## Requirements

- iOS 17+
- Swift 6.0
- Xcode 26+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/yannbonafons/PrintUI", from: "1.0.0")
]
```

## Quick Start

```swift
import PrintUI

// Log at different levels
logDebug("User tapped refresh")
logInfo("Sync completed", metadata: ["count": "42"])
logError("Network request failed", metadata: ["statusCode": "500"])
```

### Custom Subsystem & Category

```swift
logInfo("Payment processed",
        subsystem: "Checkout",
        category: "Payments")
```

### Disable Noisy Sources

```swift
disableCategories("Analytics")
disableSubsystem("Networking")
```

### Custom Log Provider

Conform to `LogProvider` to send logs anywhere:

```swift
struct CrashlyticsLogger: LogProvider {
    let enabledLevels: Set<LogLevel> = [.error]

    func log(_ event: LogEvent) {
        // forward event to Crashlytics
    }
}

registerLogProvider(CrashlyticsLogger())
```

## Architecture

```
LoggerManager          ← singleton that dispatches events
 ├─ LogProvider        ← protocol (console, remote, …)
 ├─ LogEvent          ← value type carrying level, message, metadata
 └─ LogLevel          ← .debug / .info / .error
```

## Example App

Launch the Example app located in `Example/` for a live demo of all log levels and custom providers.

## License

MIT — see [LICENSE](LICENSE).
