import Foundation

public class LoggerManager: LoggerManagerProtocol {
    private static let defaultSubsystem = Bundle.main.bundleIdentifier ?? "DefaultSubSystem"
    private static let defaultCategory = "DefaultCategory"
    
    public static var instance = LoggerManager()
    
    private let lock = NSLock()
    private var providers: [LogProvider] = []
    private var disabledCategories: [LoggerCategoryProtocol] = []
    private var disabledSubsystem: [LoggerSubsystemProtocol] = []
    
    private init() {}
    
    private func mutate(_ mutation: () -> Void) {
        lock.lock()
        mutation()
        lock.unlock()
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

    func resetProviders() {
        mutate {
            providers = []
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
        let currentProviders = providers
        lock.unlock()

        currentProviders.forEach { provider in
            guard provider.enabledLevels.contains(level),
                  provider.isProviderReady,
                  !disabledCategories.contains(where: { $0.identifier == event.category.identifier }),
                  !disabledSubsystem.contains(where: { $0.identifier == event.subsystem.identifier }) else {
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
            self.providers = providers
        }
    }
}
