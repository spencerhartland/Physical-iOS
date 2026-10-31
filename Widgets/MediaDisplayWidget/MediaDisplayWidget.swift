//
//  MediaDisplayWidget.swift
//  MediaWidget
//
//  Created by Spencer Hartland on 5/11/26.
//

import WidgetKit
import SwiftUI

struct MediaDisplayWidget: Widget {
    let kind: String = "com.spencerhartland.Physical.MediaDisplayWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectMediaIntent.self,
            provider: MediaProvider()
        ) { entry in
            MediaDisplayWidgetView(entry: entry)
        }
        .configurationDisplayName("Media Display")
        .description("Displays an item from your favorites.")
        .supportedFamilies([.systemSmall])
    }
}
