//
//  LoggerSubsystemProtocol.swift
//  PrintUI
//
//  Created by Yann Bonafons on 13/05/2026.
//

nonisolated public protocol LoggerSubsystemProtocol: Sendable {
    var identifier: String { get }
}

nonisolated extension RawRepresentable where RawValue == String, Self: LoggerSubsystemProtocol {
    public var identifier: String {
        rawValue
    }
}
