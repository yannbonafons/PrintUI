import Foundation

public let defaultLogSubsystem = "DefaultSubSystem"
public let defaultLogCategory = "DefaultCategory"

class LoggerManager {
    static let defaultSubsystem = defaultLogSubsystem
    static let defaultCategory = defaultLogCategory
    static var instance = LoggerManager()
    
    private let lock = NSLock()
    private var providers: [any LogProvider] = [ConsoleLogger()]
    private var disabledCategories: [String] = []
    private var disabledSubsystem: [String] = []
    
    private func mutate(_ mutation: () -> Void) {
        lock.lock()
        mutation()
        lock.unlock()
    }

    func disableCategories(_ categories: [String]) {
        mutate({
            disabledCategories.append(contentsOf: categories)
        })
    }

    func disableSubsystem(_ subsystems: [String]) {
        mutate({
            disabledSubsystem.append(contentsOf: subsystems)
        })
    }

    func setProviders(providers: [any LogProvider],
                      includeDefaultProvider: Bool = true) {
        mutate {
            if includeDefaultProvider {
                self.providers = [ConsoleLogger()] + providers
            } else {
                self.providers = providers
            }
        }
    }

    func resetProviders() {
        mutate {
            providers = [ConsoleLogger()]
        }
    }

    func log(
        _ level: LogLevel,
        _ message: String,
        metadata: LogMetadata = [:],
        subsystem: String = defaultSubsystem,
        category: String = defaultCategory,
        file: String = #fileID,
        line: Int = #line,
        function: String = #function
    ) {
        let event = LogEvent(
            level: level,
            message: message,
            subsystem: subsystem,
            category: category,
            metadata: defaultMetadata(
                metadata: metadata,
                file: file,
                line: line,
                function: function
            )
        )

        lock.lock()
        let currentProviders = providers
        lock.unlock()

        currentProviders.forEach { provider in
            guard provider.enabledLevels.contains(level),
                  provider.isProviderReady,
                  !disabledSubsystem.contains(subsystem),
                  !disabledCategories.contains(category) else {
                return
            }
            provider.log(event)
        }
    }

    private func defaultMetadata(
        metadata: LogMetadata,
        file: String,
        line: Int,
        function: String
    ) -> LogMetadata {
        var finalMetadata: LogMetadata = [
            "file": file,
            "line": String(line),
            "function": function
        ]

        metadata.forEach { key, value in
            finalMetadata[key] = value
        }

        return finalMetadata
    }
}

public func logDebug(
    _ message: String,
    metadata: LogMetadata = [:],
    subsystem: String = defaultLogSubsystem,
    category: String = defaultLogCategory,
    file: String = #fileID,
    line: Int = #line,
    function: String = #function
) {
    LoggerManager.instance.log(
        .debug,
        message,
        metadata: metadata,
        subsystem: subsystem,
        category: category,
        file: file,
        line: line,
        function: function
    )
}

public func logInfo(
    _ message: String,
    metadata: LogMetadata = [:],
    subsystem: String = defaultLogSubsystem,
    category: String = defaultLogCategory,
    file: String = #fileID,
    line: Int = #line,
    function: String = #function
) {
    LoggerManager.instance.log(
        .info,
        message,
        metadata: metadata,
        subsystem: subsystem,
        category: category,
        file: file,
        line: line,
        function: function
    )
}

public func logError(
    _ message: String,
    metadata: LogMetadata = [:],
    subsystem: String = defaultLogSubsystem,
    category: String = defaultLogCategory,
    file: String = #fileID,
    line: Int = #line,
    function: String = #function
) {
    LoggerManager.instance.log(
        .error,
        message,
        metadata: metadata,
        subsystem: subsystem,
        category: category,
        file: file,
        line: line,
        function: function
    )
}

public func registerLogProvider(_ providers: (any LogProvider)...) {
    LoggerManager.instance.setProviders(providers: providers)
}

public func disableCategories(_ categories: String...) {
    LoggerManager.instance.disableCategories(categories)
}

public func disableSubsystem(_ subsystems: String...) {
    LoggerManager.instance.disableSubsystem(subsystems)
}
