//
//  LogLevel.swift
//  PrintUI
//
//  Created by Yann Bonafons on 01/04/2026.
//

public enum LogLevel: String, CaseIterable, Comparable, Sendable {
    case debug
    case info
    case error

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rank < rhs.rank
    }

    private var rank: Int {
        switch self {
        case .debug: return 0
        case .info: return 1
        case .error: return 2
        }
    }

    var prefix: String {
        switch self {
        case .debug: return "[DEBUG]"
        case .info: return "[INFO]"
        case .error: return "[ERROR]"
        }
    }
}
