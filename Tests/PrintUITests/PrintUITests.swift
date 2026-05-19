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
        #expect(event.subsystem.identifier == "Sub")
        #expect(event.category.identifier == "Cat")
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
        LoggerManager.instance.setProviders(providers: [spy])

        logInfo("test message")

        #expect(spy.capturedEvents.count == 1)
        #expect(spy.capturedEvents.first?.message == "test message")
        #expect(spy.capturedEvents.first?.level == .info)
    }

    @Test("Dispatches to multiple providers")
    func multipleProviders() {
        let spy1 = SpyLogProvider()
        let spy2 = SpyLogProvider()
        LoggerManager.instance.setProviders(providers: [spy1, spy2])

        logDebug("multi")

        #expect(spy1.capturedEvents.count == 1)
        #expect(spy2.capturedEvents.count == 1)
    }

    // MARK: Level filtering

    @Test("Skips provider when level is not enabled")
    func levelFiltering() {
        let errorOnly = SpyLogProvider(enabledLevels: [.error])
        LoggerManager.instance.setProviders(providers: [errorOnly])

        logDebug("ignored")
        logInfo("ignored")
        logError("captured")

        #expect(errorOnly.capturedEvents.count == 1)
        #expect(errorOnly.capturedEvents.first?.level == .error)
    }

    // MARK: Provider readiness

    @Test("Skips provider when isProviderReady is false")
    func providerNotReady() {
        let notReady = SpyLogProvider(isProviderReady: false)
        LoggerManager.instance.setProviders(providers: [notReady])

        logInfo("should be skipped")

        #expect(notReady.capturedEvents.isEmpty)
    }

    // MARK: Metadata

    @Test("Includes default metadata (file, line, function)")
    func defaultMetadata() {
        let spy = SpyLogProvider()
        LoggerManager.instance.setProviders(providers: [spy])

        logInfo("meta test")

        let metadata = spy.capturedEvents.first?.metadata
        #expect(metadata?["file"] != nil)
        #expect(metadata?["line"] != nil)
        #expect(metadata?["function"] != nil)
    }

    @Test("User metadata merges with default metadata")
    func customMetadata() {
        let spy = SpyLogProvider()
        LoggerManager.instance.setProviders(providers: [spy])

        logInfo("meta", metadata: ["userId": "123"])

        let metadata = spy.capturedEvents.first?.metadata
        #expect(metadata?["userId"] == "123")
        #expect(metadata?["file"] != nil)
    }

    // MARK: Subsystem & category

    @Test("Uses default subsystem and category")
    func defaults() {
        let spy = SpyLogProvider()
        LoggerManager.instance.setProviders(providers: [spy])

        logInfo("defaults")

        let event = spy.capturedEvents.first
        #expect(event?.category.identifier == LoggerManager.instance.getDefaultCategory().identifier)
    }

    @Test("Custom subsystem and category are forwarded")
    func customSubsystemCategory() {
        let spy = SpyLogProvider()
        LoggerManager.instance.setProviders(providers: [spy])

        logInfo("custom", subsystem: "MySub", category: "MyCat")

        let event = spy.capturedEvents.first
        #expect(event?.subsystem.identifier == "MySub")
        #expect(event?.category.identifier == "MyCat")
    }

    // MARK: Disable categories / subsystems

    @Test("Disabled categories are filtered out")
    func disableCategories() {
        let spy = SpyLogProvider()
        LoggerManager.instance.setProviders(providers: [spy])
        LoggerManager.instance.disableCategories(["Analytics"])
        
        logInfo("visible", category: "General")
        logInfo("hidden", category: "Analytics")

        #expect(spy.capturedEvents.count == 1)
        #expect(spy.capturedEvents.first?.message == "visible")
    }

    @Test("Disabled subsystems are filtered out")
    func disableSubsystem() {
        let spy = SpyLogProvider()
        LoggerManager.instance.setProviders(providers: [spy])
        LoggerManager.instance.disableSubsystems(["Networking"])
        
        logInfo("visible", subsystem: "UI")
        logInfo("hidden", subsystem: "Networking")

        #expect(spy.capturedEvents.count == 1)
        #expect(spy.capturedEvents.first?.message == "visible")
    }

    // MARK: setProviders / resetProviders

    @Test("setProviders replaces existing providers")
    func setProviders() {
        let spy1 = SpyLogProvider()
        let spy2 = SpyLogProvider()
        LoggerManager.instance.setProviders(providers: [spy1])
        LoggerManager.instance.setProviders(providers: [spy2])
        
        logInfo("only spy2")

        #expect(spy1.capturedEvents.isEmpty)
        #expect(spy2.capturedEvents.count == 1)
    }

    @Test("resetProviders restores default ConsoleLogger")
    func resetProviders() {
        let spy = SpyLogProvider()
        LoggerManager.instance.setProviders(providers: [spy])

        LoggerManager.instance.reset()
        logInfo("after reset")

        // Spy should no longer receive events after reset
        #expect(spy.capturedEvents.isEmpty)
    }
}

// MARK: - Public API (free functions) Tests

@Suite("Public API free functions")
struct PublicAPITests {
    private func configuredManager() -> SpyLogProvider {
        let spy = SpyLogProvider()
        LoggerManager.instance.setProviders(providers: [spy])
        return spy
    }

    @Test("logDebug dispatches .debug event")
    func logDebugFunction() {
        let spy = configuredManager()
        logDebug("debug msg")
        #expect(spy.capturedEvents.last?.level == .debug)
        #expect(spy.capturedEvents.last?.message == "debug msg")
        LoggerManager.instance.reset()
    }

    @Test("logInfo dispatches .info event")
    func logInfoFunction() {
        let spy = configuredManager()
        logInfo("info msg")
        #expect(spy.capturedEvents.last?.level == .info)
        #expect(spy.capturedEvents.last?.message == "info msg")
        LoggerManager.instance.reset()
    }

    @Test("logError dispatches .error event")
    func logErrorFunction() {
        let spy = configuredManager()
        logError("error msg")
        #expect(spy.capturedEvents.last?.level == .error)
        #expect(spy.capturedEvents.last?.message == "error msg")
        LoggerManager.instance.reset()
    }

    @Test("disableCategories filters via singleton")
    func disableCategoriesFunction() {
        let spy = configuredManager()
        LoggerManager.instance.disableCategories(["Noisy"])
        logInfo("visible", category: "General")
        logInfo("hidden", category: "Noisy")
        #expect(spy.capturedEvents.count == 1)
        LoggerManager.instance.reset()
    }

    @Test("disableSubsystem filters via singleton")
    func disableSubsystemFunction() {
        let spy = configuredManager()
        LoggerManager.instance.disableSubsystems(["Net"])
        logInfo("visible", subsystem: "UI")
        logInfo("hidden", subsystem: "Net")
        #expect(spy.capturedEvents.count == 1)
        LoggerManager.instance.reset()
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
