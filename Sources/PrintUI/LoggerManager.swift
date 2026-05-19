import Foundation

nonisolated public final class LoggerManager: LoggerManagerProtocol {
    private static let defaultSubsystem = Bundle.main.bundleIdentifier ?? "DefaultSubSystem"
    private static let defaultCategory = "DefaultCategory"
    
    public static let instance = LoggerManager()
    
    private let lock = NSLock()
    nonisolated(unsafe) private var providers: [LogProvider] = [ConsoleLogger()]
    nonisolated(unsafe) private var disabledCategories: [LoggerCategoryProtocol] = []
    nonisolated(unsafe) private var disabledSubsystem: [LoggerSubsystemProtocol] = []
    
    private init() {}
    
    private func mutate(_ mutation: () -> Void) {
        lock.lock()
        defer { lock.unlock() }
        mutation()
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

extension LoggerManager {
    func getDefaultCategory() -> LoggerCategoryProtocol {
        LoggerManager.defaultCategory
    }

    func getDefaultSubsystem(file: String) -> LoggerSubsystemProtocol {
        file.components(separatedBy: "/").first ?? LoggerManager.defaultSubsystem
    }

    func reset() {
        mutate {
            providers = [ConsoleLogger()]
            disabledCategories = []
            disabledSubsystem = []
        }
    }

    func log(
        _ level: LogLevel,
        _ message: String,
        metadata: LogMetadata = [:],
        subsystem: LoggerSubsystemProtocol?,
        category: LoggerCategoryProtocol?,
        file: String,
        line: Int,
        function: String
    ) {
        let event = LogEvent(
            level: level,
            message: message,
            subsystem: subsystem ?? getDefaultSubsystem(file: file),
            category: category ?? getDefaultCategory(),
            metadata: defaultMetadata(
                metadata: metadata,
                file: file,
                line: line,
                function: function
            )
        )

        lock.lock()
        defer { lock.unlock() }
        let currentProviders = providers
        let currentDisableCategories = disabledCategories
        let currentDisableSubsystem = disabledSubsystem

        currentProviders.forEach { provider in
            guard provider.enabledLevels.contains(level),
                  provider.isProviderReady,
                  !currentDisableCategories.contains(where: { $0.identifier == event.category.identifier }),
                  !currentDisableSubsystem.contains(where: { $0.identifier == event.subsystem.identifier }) else {
                return
            }
            provider.log(event)
        }
    }

}

extension LoggerManager {
    public func disableCategories(_ categories: [LoggerCategoryProtocol]) {
        mutate({
            disabledCategories.append(contentsOf: categories)
        })
    }

    public func disableSubsystems(_ subsystems: [LoggerSubsystemProtocol]) {
        mutate({
            disabledSubsystem.append(contentsOf: subsystems)
        })
    }

    public func disableDefaultSubsystem(file: String = #fileID) {
        disableSubsystems([getDefaultSubsystem(file: file)])
    }

    public func disableDefaultCategory() {
        disableCategories([getDefaultCategory()])
    }

    public func setProviders(providers: [LogProvider]) {
        mutate {
            var newProviders = providers
            newProviders.append(ConsoleLogger())
            self.providers = newProviders
        }
    }
}
