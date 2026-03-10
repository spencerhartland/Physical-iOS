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
    /// Networking and API request logging.
    static let network = Logger(subsystem: subsystem, category: "network")
    /// Authentication flow logging.
    static let authentication = Logger(subsystem: subsystem, category: "authentication")
    /// SwiftData and persistence logging.
    static let database = Logger(subsystem: subsystem, category: "database")
    /// View lifecycle and UI event logging.
    static let ui = Logger(subsystem: subsystem, category: "ui")
}
