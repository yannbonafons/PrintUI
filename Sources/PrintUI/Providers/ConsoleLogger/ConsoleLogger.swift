//
//  RemoteLogger.swift
//  PrintUI
//
//  Created by Yann Bonafons on 01/04/2026.
//

import Foundation
import OSLog

public struct ConsoleLogger: LogProvider {
    private struct LoggerKey: Hashable {
        let subsystem: String
        let category: String
    }

    private static let loggerCacheLock = NSLock()
    private static var loggerCache: [LoggerKey: Logger] = [:]

    public let enabledLevels: Set<LogLevel>
    public let defaultSubsystem: String
    public let defaultCategory: String

    public init(
        enabledLevels: Set<LogLevel> = Set(LogLevel.allCases),
        subsystem: String = Bundle.main.bundleIdentifier ?? "PrintUI",
        category: String = "default"
    ) {
        self.enabledLevels = enabledLevels
        self.defaultSubsystem = subsystem
        self.defaultCategory = category
    }

    public func log(_ event: LogEvent) {
        guard enabledLevels.contains(event.level) else { return }

        let subsystem = event.metadata["subsystem"] ?? defaultSubsystem
        let category = event.metadata["category"] ?? defaultCategory

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
        let filteredMetadata = event.metadata
            .filter { key, _ in key != "subsystem" && key != "category" }
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")

        if filteredMetadata.isEmpty {
            return "\(event.level.prefix) \(event.message)"
        }

        return "\(event.level.prefix) \(event.message) | \(filteredMetadata)"
    }

    private func cachedLogger(subsystem: String, category: String) -> Logger {
        let key = LoggerKey(subsystem: subsystem, category: category)

        Self.loggerCacheLock.lock()
        defer { Self.loggerCacheLock.unlock() }

        if let cachedLogger = Self.loggerCache[key] {
            return cachedLogger
        }

        let logger = Logger(subsystem: subsystem, category: category)
        Self.loggerCache[key] = logger
        return logger
    }
}
