//
//  LoggerCategoryProtocol.swift
//  PrintUI
//
//  Created by Yann Bonafons on 13/05/2026.
//

nonisolated public protocol LoggerCategoryProtocol: Sendable {
    var identifier: String { get }
}

nonisolated extension RawRepresentable where RawValue == String, Self: LoggerCategoryProtocol {
    public var identifier: String {
        rawValue
    }
}
