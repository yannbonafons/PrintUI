//
//  LogEvent.swift
//  PrintUI
//
//  Created by Yann Bonafons on 01/04/2026.
//

nonisolated public struct LogEvent: Sendable {
    public let level: LogLevel
    public let message: String
    public let subsystem: any LoggerSubsystemProtocol
    public let category: any LoggerCategoryProtocol
    public let metadata: LogMetadata

    public init(level: LogLevel,
                message: String,
                subsystem: any LoggerSubsystemProtocol,
                category: any LoggerCategoryProtocol,
                metadata: LogMetadata = [:]) {
        self.level = level
        self.message = message
        self.subsystem = subsystem
        self.category = category
        self.metadata = metadata
    }
}
