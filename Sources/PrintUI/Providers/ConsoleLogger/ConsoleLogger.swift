//
//  RemoteLogger.swift
//  PrintUI
//
//  Created by Yann Bonafons on 01/04/2026.
//

import Foundation
import OSLog

nonisolated public struct ConsoleLogger: LogProvider {
    private struct LoggerKey: Hashable {
        let subsystem: String
        let category: String
    }

    private static let loggerCacheLock = NSLock()
    nonisolated(unsafe) private static var loggerCache: [LoggerKey: Logger] = [:]

    public let enabledLevels: Set<LogLevel>

    public init(enabledLevels: Set<LogLevel> = Set(LogLevel.allCases)) {
        self.enabledLevels = enabledLevels
    }

    public func log(_ event: LogEvent) {
        guard enabledLevels.contains(event.level) else {
            return
        }

        let subsystem = event.subsystem.identifier
        let category = event.category.identifier

        let logger = cachedLogger(subsystem: subsystem, category: category)
        let payload = formattedPayload(for: event)

        switch event.level {
        case .debug:
            logger.debug("\(payload, privacy: .public)")
        case .info:
            logger.info("\(payload, privacy: .public)")
        case .error:
            logger.error("\(payload, privacy: .public)")
        }
    }

    private func formattedPayload(for event: LogEvent) -> String {
        let metadata = event.metadata
            .sorted { $0.key < $1.key }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")

        let fullMessage = "\(event.level.prefix) - \(event.message)"
        if metadata.isEmpty {
            return fullMessage
        } else {
            return "\(fullMessage)\n- Metadata:\n\(metadata)"
        }
    }

    private func cachedLogger(subsystem: String, category: String) -> Logger {
        let key = LoggerKey(subsystem: subsystem, category: category)

        ConsoleLogger.loggerCacheLock.lock()
        defer { ConsoleLogger.loggerCacheLock.unlock() }

        if let cachedLogger = ConsoleLogger.loggerCache[key] {
            return cachedLogger
        }

        let logger = Logger(subsystem: subsystem, category: category)
        ConsoleLogger.loggerCache[key] = logger
        return logger
    }
}
