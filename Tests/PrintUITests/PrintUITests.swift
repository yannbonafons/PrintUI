import Testing
@testable import PrintUI

// MARK: - Spy Provider

final class SpyLogProvider: LogProvider, @unchecked Sendable {
    let enabledLevels: Set<LogLevel>
    let isProviderReady: Bool
    private(set) var capturedEvents: [LogEvent] = []

    init(
        enabledLevels: Set<LogLevel> = Set(LogLevel.allCases),
        isProviderReady: Bool = true
    ) {
        self.enabledLevels = enabledLevels
        self.isProviderReady = isProviderReady
    }

    func log(_ event: LogEvent) {
        capturedEvents.append(event)
    }
}

// MARK: - Helpers

private func freshManager(providers: [any LogProvider] = []) -> LoggerManager {
    let manager = LoggerManager()
    manager.setProviders(providers: providers, includeDefaultProvider: false)
    return manager
}

// MARK: - LogLevel Tests

@Suite("LogLevel")
struct LogLevelTests {
    @Test("Comparable ordering: debug < info < error")
    func ordering() {
        #expect(LogLevel.debug < .info)
        #expect(LogLevel.info < .error)
        #expect(LogLevel.debug < .error)
        #expect(!(LogLevel.error < .debug))
    }

    @Test("Prefix strings")
    func prefixes() {
        #expect(LogLevel.debug.prefix == "[DEBUG]")
        #expect(LogLevel.info.prefix == "[INFO]")
        #expect(LogLevel.error.prefix == "[ERROR]")
    }

    @Test("CaseIterable contains all cases")
    func allCases() {
        #expect(LogLevel.allCases.count == 3)
        #expect(LogLevel.allCases.contains(.debug))
        #expect(LogLevel.allCases.contains(.info))
        #expect(LogLevel.allCases.contains(.error))
    }
}

// MARK: - LogEvent Tests

@Suite("LogEvent")
struct LogEventTests {
    @Test("Stores all properties")
    func properties() {
        let event = LogEvent(
            level: .info,
            message: "hello",
            subsystem: "Sub",
            category: "Cat",
            metadata: ["key": "value"]
        )

        #expect(event.level == .info)
        #expect(event.message == "hello")
        #expect(event.subsystem == "Sub")
        #expect(event.category == "Cat")
        #expect(event.metadata["key"] == "value")
    }

    @Test("Default metadata is empty")
    func defaultMetadata() {
        let event = LogEvent(level: .debug, message: "msg", subsystem: "s", category: "c")
        #expect(event.metadata.isEmpty)
    }
}

// MARK: - LoggerManager Tests

@Suite("LoggerManager")
struct LoggerManagerTests {

    // MARK: Basic dispatch

    @Test("Dispatches event to registered provider")
    func basicDispatch() {
        let spy = SpyLogProvider()
        let manager = freshManager(providers: [spy])

        manager.log(.info, "test message")

        #expect(spy.capturedEvents.count == 1)
        #expect(spy.capturedEvents.first?.message == "test message")
        #expect(spy.capturedEvents.first?.level == .info)
    }

    @Test("Dispatches to multiple providers")
    func multipleProviders() {
        let spy1 = SpyLogProvider()
        let spy2 = SpyLogProvider()
        let manager = freshManager(providers: [spy1, spy2])

        manager.log(.debug, "multi")

        #expect(spy1.capturedEvents.count == 1)
        #expect(spy2.capturedEvents.count == 1)
    }

    // MARK: Level filtering

    @Test("Skips provider when level is not enabled")
    func levelFiltering() {
        let errorOnly = SpyLogProvider(enabledLevels: [.error])
        let manager = freshManager(providers: [errorOnly])

        manager.log(.debug, "ignored")
        manager.log(.info, "ignored")
        manager.log(.error, "captured")

        #expect(errorOnly.capturedEvents.count == 1)
        #expect(errorOnly.capturedEvents.first?.level == .error)
    }

    // MARK: Provider readiness

    @Test("Skips provider when isProviderReady is false")
    func providerNotReady() {
        let notReady = SpyLogProvider(isProviderReady: false)
        let manager = freshManager(providers: [notReady])

        manager.log(.info, "should be skipped")

        #expect(notReady.capturedEvents.isEmpty)
    }

    // MARK: Metadata

    @Test("Includes default metadata (file, line, function)")
    func defaultMetadata() {
        let spy = SpyLogProvider()
        let manager = freshManager(providers: [spy])

        manager.log(.info, "meta test")

        let metadata = spy.capturedEvents.first?.metadata
        #expect(metadata?["file"] != nil)
        #expect(metadata?["line"] != nil)
        #expect(metadata?["function"] != nil)
    }

    @Test("User metadata merges with default metadata")
    func customMetadata() {
        let spy = SpyLogProvider()
        let manager = freshManager(providers: [spy])

        manager.log(.info, "meta", metadata: ["userId": "123"])

        let metadata = spy.capturedEvents.first?.metadata
        #expect(metadata?["userId"] == "123")
        #expect(metadata?["file"] != nil)
    }

    // MARK: Subsystem & category

    @Test("Uses default subsystem and category")
    func defaults() {
        let spy = SpyLogProvider()
        let manager = freshManager(providers: [spy])

        manager.log(.info, "defaults")

        let event = spy.capturedEvents.first
        #expect(event?.subsystem == LoggerManager.defaultSubsystem)
        #expect(event?.category == LoggerManager.defaultCategory)
    }

    @Test("Custom subsystem and category are forwarded")
    func customSubsystemCategory() {
        let spy = SpyLogProvider()
        let manager = freshManager(providers: [spy])

        manager.log(.info, "custom", subsystem: "MySub", category: "MyCat")

        let event = spy.capturedEvents.first
        #expect(event?.subsystem == "MySub")
        #expect(event?.category == "MyCat")
    }

    // MARK: Disable categories / subsystems

    @Test("Disabled categories are filtered out")
    func disableCategories() {
        let spy = SpyLogProvider()
        let manager = freshManager(providers: [spy])

        manager.disableCategories(["Analytics"])
        manager.log(.info, "visible", category: "General")
        manager.log(.info, "hidden", category: "Analytics")

        #expect(spy.capturedEvents.count == 1)
        #expect(spy.capturedEvents.first?.message == "visible")
    }

    @Test("Disabled subsystems are filtered out")
    func disableSubsystem() {
        let spy = SpyLogProvider()
        let manager = freshManager(providers: [spy])

        manager.disableSubsystem(["Networking"])
        manager.log(.info, "visible", subsystem: "UI")
        manager.log(.info, "hidden", subsystem: "Networking")

        #expect(spy.capturedEvents.count == 1)
        #expect(spy.capturedEvents.first?.message == "visible")
    }

    // MARK: setProviders / resetProviders

    @Test("setProviders replaces existing providers")
    func setProviders() {
        let spy1 = SpyLogProvider()
        let spy2 = SpyLogProvider()
        let manager = freshManager(providers: [spy1])

        manager.setProviders(providers: [spy2], includeDefaultProvider: false)
        manager.log(.info, "only spy2")

        #expect(spy1.capturedEvents.isEmpty)
        #expect(spy2.capturedEvents.count == 1)
    }

    @Test("resetProviders restores default ConsoleLogger")
    func resetProviders() {
        let spy = SpyLogProvider()
        let manager = freshManager(providers: [spy])

        manager.resetProviders()
        manager.log(.info, "after reset")

        // Spy should no longer receive events after reset
        #expect(spy.capturedEvents.isEmpty)
    }
}

// MARK: - Public API (free functions) Tests

@Suite("Public API free functions")
struct PublicAPITests {
    private func configuredManager() -> (LoggerManager, SpyLogProvider) {
        let spy = SpyLogProvider()
        let manager = LoggerManager.instance
        manager.setProviders(providers: [spy], includeDefaultProvider: false)
        return (manager, spy)
    }

    @Test("logDebug dispatches .debug event")
    func logDebugFunction() {
        let (_, spy) = configuredManager()
        logDebug("debug msg")
        #expect(spy.capturedEvents.last?.level == .debug)
        #expect(spy.capturedEvents.last?.message == "debug msg")
        LoggerManager.instance.resetProviders()
    }

    @Test("logInfo dispatches .info event")
    func logInfoFunction() {
        let (_, spy) = configuredManager()
        logInfo("info msg")
        #expect(spy.capturedEvents.last?.level == .info)
        #expect(spy.capturedEvents.last?.message == "info msg")
        LoggerManager.instance.resetProviders()
    }

    @Test("logError dispatches .error event")
    func logErrorFunction() {
        let (_, spy) = configuredManager()
        logError("error msg")
        #expect(spy.capturedEvents.last?.level == .error)
        #expect(spy.capturedEvents.last?.message == "error msg")
        LoggerManager.instance.resetProviders()
    }

    @Test("registerLogProvider adds provider via singleton")
    func registerProvider() {
        let spy = SpyLogProvider()
        LoggerManager.instance.setProviders(providers: [], includeDefaultProvider: false)
        registerLogProvider(spy)
        logInfo("after register")
        #expect(spy.capturedEvents.last?.message == "after register")
        LoggerManager.instance.resetProviders()
    }

    @Test("disableCategories filters via singleton")
    func disableCategoriesFunction() {
        let (_, spy) = configuredManager()
        disableCategories("Noisy")
        logInfo("visible", category: "General")
        logInfo("hidden", category: "Noisy")
        #expect(spy.capturedEvents.count == 1)
        LoggerManager.instance.resetProviders()
    }

    @Test("disableSubsystem filters via singleton")
    func disableSubsystemFunction() {
        let (_, spy) = configuredManager()
        disableSubsystem("Net")
        logInfo("visible", subsystem: "UI")
        logInfo("hidden", subsystem: "Net")
        #expect(spy.capturedEvents.count == 1)
        LoggerManager.instance.resetProviders()
    }
}

// MARK: - ConsoleLogger Unit Tests

@Suite("ConsoleLogger")
struct ConsoleLoggerTests {
    @Test("Default init enables all levels")
    func defaultLevels() {
        let logger = ConsoleLogger()
        #expect(logger.enabledLevels == Set(LogLevel.allCases))
    }

    @Test("Custom init restricts levels")
    func customLevels() {
        let logger = ConsoleLogger(enabledLevels: [.error])
        #expect(logger.enabledLevels == [.error])
    }

    @Test("isProviderReady is true by default")
    func readyByDefault() {
        let logger = ConsoleLogger()
        #expect(logger.isProviderReady)
    }
}
