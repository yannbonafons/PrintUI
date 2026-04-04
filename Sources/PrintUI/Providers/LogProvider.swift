//
//  LogProvider.swift
//  PrintUI
//
//  Created by Yann Bonafons on 01/04/2026.
//

public protocol LogProvider: Sendable {
    var enabledLevels: Set<LogLevel> { get }
    var isProviderReady: Bool { get }

    func log(_ event: LogEvent)
}

public extension LogProvider {
    var isProviderReady: Bool {
        true
    }
}
