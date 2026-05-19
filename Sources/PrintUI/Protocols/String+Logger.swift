//
//  String+Logger.swift
//  PrintUI
//
//  Created by Yann Bonafons on 13/05/2026.
//

extension String: LoggerCategoryProtocol, LoggerSubsystemProtocol {
    public var identifier: String {
        self
    }
}
