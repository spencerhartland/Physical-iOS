//
//  Log.swift
//  Physical
//
//  Created by Spencer Hartland on 2/6/26.
//

import OSLog

final class Log {
    private static let subsystem: String = "com.spencerhartland.Physical"
    
    /// General app-level logging.
    static let general = Logger(subsystem: subsystem, category: "general")
    /// SwiftData and persistence logging.
    static let storage = Logger(subsystem: subsystem, category: "storage")
    /// View lifecycle and UI event logging.
    static let ui = Logger(subsystem: subsystem, category: "ui")
}
