//
//  Log.swift
//  Physical
//
//  Created by Spencer Hartland on 10/30/26.
//

import OSLog

extension Logger {
    private static let subsystem = "com.spencerhartland.Physical.Widgets"
    
    private struct Category {
        static let general: String = "general"
        static let timelineProvider: String = "timelineProvider"
        static let ui: String = "ui"
    }
    
    static let general = Logger(subsystem: subsystem, category: Category.general)
    static let timelineProvider = Logger(subsystem: subsystem, category: Category.timelineProvider)
    static let ui = Logger(subsystem: subsystem, category: Category.ui)
}
