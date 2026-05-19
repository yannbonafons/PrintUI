//
//  String+Logger.swift
//  PrintUI
//
//  Created by Yann Bonafons on 13/05/2026.
//

nonisolated extension String: LoggerCategoryProtocol, LoggerSubsystemProtocol {
    public var identifier: String {
        self
    }
}
