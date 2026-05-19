//
//  LoggerManagerProtocol.swift
//  PrintUI
//
//  Created by Yann Bonafons on 13/05/2026.
//

public protocol LoggerManagerProtocol {
    func disableCategories(_ categories: [LoggerCategoryProtocol])
    func disableSubsystems(_ subsystems: [LoggerSubsystemProtocol])
    func disableDefaultSubsystem(file: String)
    func disableDefaultCategory()
    func setProviders(providers: [LogProvider])
}
