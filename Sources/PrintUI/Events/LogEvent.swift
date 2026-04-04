//
//  LogEvent.swift
//  PrintUI
//
//  Created by Yann Bonafons on 01/04/2026.
//

public struct LogEvent: Sendable {
    public let level: LogLevel
    public let message: String
    public let subsystem: String
    public let category: String
    public let metadata: LogMetadata

    public init(level: LogLevel,
                message: String,
                subsystem: String,
                category: String,
                metadata: LogMetadata = [:]) {
        self.level = level
        self.message = message
        self.subsystem = subsystem
        self.category = category
        self.metadata = metadata
    }
}

public typealias LogMetadata = [String: String]
