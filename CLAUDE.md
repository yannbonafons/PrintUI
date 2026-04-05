# PrintUI

Lightweight, provider-based logging library for Swift.

## Project structure

```
Sources/PrintUI/
  Events/                   # LogEvent, LogLevel, LogMetadata
  Providers/                # LogProvider protocol + built-in ConsoleLogger
  LoggerManager.swift       # Singleton dispatcher + public free functions
Tests/PrintUITests/         # Unit tests (Swift Testing)
Example/PrintUIApp/         # Demo app (Xcode project via project.yml)
```

## Stack

- Swift 6, strict concurrency (`actor`, `Sendable`)
- SPM (swift-tools-version: 6.2)
- Minimum deployment: iOS 17
- Testing framework: Swift Testing (`import Testing`)
- Approachable concurrency: YES
- Default actor isolation: MainActor
- Strict concurrency checking: Complete
- SwiftLint via SPM build tool plugin

## Architecture

- **LoggerManager** – `internal` singleton (`LoggerManager.instance`) that holds an array of `LogProvider`s and dispatches `LogEvent`s.
- **LogProvider** – `public` protocol. Each provider declares its `enabledLevels` and receives filtered events via `log(_:)`.
- **ConsoleLogger** – Default built-in provider wrapping `os.Logger` with a per-subsystem/category cache.
- **Public API** – Free functions (`logDebug`, `logInfo`, `logError`, `registerLogProvider`, `disableCategories`, `disableSubsystem`) that delegate to `LoggerManager.instance`.

### Access Control Convention

- `public` only on types/members that the consumer module needs

## Code Style

- **4-space indentation**
- **PascalCase** for types, **camelCase** for properties/methods
- **@Observable** classes (only use Combine when @Observable is not enough)
- **Swift concurrency** (async/await) over Combine
- **Swift Testing** for unit tests (not XCTest)
- No force unwrapping
- Prefer `let` over `var`
- `public` only where necessary for cross-module access
- ViewModifiers exposed via View extensions (ViewModifier is private)
- MARK: comments to organize file sections
- Doc comments (`///`) on public API
