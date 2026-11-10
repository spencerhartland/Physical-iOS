//
//  Log.swift
//  Physical
//
//  Created by Spencer Hartland on 10/30/26.
//

import OSLog

extension Logger {
    private struct Subsystem {
        static let app = "com.spencerhartland.Physical"
        static let widget = "com.spencerhartland.Physical.Widgets"
    }
    
    private struct Category {
        static let general: String = "general"
        static let storage: String = "storage"
        static let timelineProvider: String = "timelineProvider"
        static let ui: String = "ui"
    }
    
    struct Standard {
        static let general = Logger(subsystem: Subsystem.app, category: Category.general)
        static let storage = Logger(subsystem: Subsystem.app, category: Category.storage)
        static let ui = Logger(subsystem: Subsystem.app, category: Category.ui)
    }
    
    struct Widget {
        static let general = Logger(subsystem: Subsystem.widget, category: Category.general)
        static let timelineProvider = Logger(subsystem: Subsystem.widget, category: Category.timelineProvider)
        static let ui = Logger(subsystem: Subsystem.widget, category: Category.ui)
    }
}
