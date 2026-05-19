//
//  LoggerCategoryProtocol.swift
//  PrintUI
//
//  Created by Yann Bonafons on 13/05/2026.
//

public protocol LoggerCategoryProtocol {
    var identifier: String { get }
}

extension RawRepresentable where RawValue == String, Self: LoggerCategoryProtocol {
    public var identifier: String {
        rawValue
    }
}
