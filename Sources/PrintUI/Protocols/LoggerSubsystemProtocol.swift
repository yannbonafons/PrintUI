//
//  LoggerSubsystemProtocol.swift
//  PrintUI
//
//  Created by Yann Bonafons on 13/05/2026.
//

public protocol LoggerSubsystemProtocol {
    var identifier: String { get }
}

extension RawRepresentable where RawValue == String, Self: LoggerSubsystemProtocol {
    public var identifier: String {
        rawValue
    }
}
