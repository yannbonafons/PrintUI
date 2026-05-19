//
//  LoggerGlobalFunctions.swift
//  PrintUI
//
//  Created by Yann Bonafons on 11/05/2026.
//

public func logDebug(
    _ message: String,
    metadata: LogMetadata = [:],
    subsystem: LoggerSubsystemProtocol? = nil,
    category: LoggerCategoryProtocol? = nil,
    file: String = #fileID,
    line: Int = #line,
    function: String = #function
) {
    LoggerManager.instance.log(
        .debug,
        message,
        metadata: metadata,
        subsystem: subsystem,
        category: category,
        file: file,
        line: line,
        function: function
    )
}

public func logInfo(
    _ message: String,
    metadata: LogMetadata = [:],
    subsystem: LoggerSubsystemProtocol? = nil,
    category: LoggerCategoryProtocol? = nil,
    file: String = #fileID,
    line: Int = #line,
    function: String = #function
) {
    LoggerManager.instance.log(
        .info,
        message,
        metadata: metadata,
        subsystem: subsystem,
        category: category,
        file: file,
        line: line,
        function: function
    )
}

public func logError(
    _ message: String,
    metadata: LogMetadata = [:],
    subsystem: LoggerSubsystemProtocol? = nil,
    category: LoggerCategoryProtocol? = nil,
    file: String = #fileID,
    line: Int = #line,
    function: String = #function
) {
    LoggerManager.instance.log(
        .error,
        message,
        metadata: metadata,
        subsystem: subsystem,
        category: category,
        file: file,
        line: line,
        function: function
    )
}
