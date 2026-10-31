//
//  FavoritesDisplayWidget.swift
//  PhysicalMediaWidgetExtension
//
//  Created by Spencer Hartland on 5/18/26.
//

import WidgetKit
import SwiftUI

struct FavoritesDisplayWidget: Widget {
    let kind: String = "com.spencerhartland.Physical.FavoritesDisplayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: MediaProvider()
        ) { entry in
            FavoritesDisplayWidgetView(entry: entry)
        }
        .configurationDisplayName("Favorites Display")
        .description("Displays your favorite media.")
        .supportedFamilies([.systemSmall])
    }
}
