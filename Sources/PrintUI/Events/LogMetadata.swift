//
//  LogMetadata.swift
//  PrintUI
//
//  Created by Yann Bonafons on 11/05/2026.
//

public typealias LogMetadata = [String: String]

public nonisolated extension String {
    /// Use this key into your LogMetadata in order to find errors easily
    static var error: String {
        "error"
    }
}
