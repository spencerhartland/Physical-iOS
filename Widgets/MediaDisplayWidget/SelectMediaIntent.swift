//
//  SelectMediaIntent.swift
//  Physical
//
//  Created by Spencer Hartland on 5/11/26.
//

import Foundation
import AppIntents

struct SelectMediaIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Media"
    static var description = IntentDescription("Select an item from your favorites to display.")
    
    @Parameter(title: "Media")
    var media: MediaEntity?
    
    init(media: MediaEntity?) {
        self.media = media
    }
    
    init() {}
}
