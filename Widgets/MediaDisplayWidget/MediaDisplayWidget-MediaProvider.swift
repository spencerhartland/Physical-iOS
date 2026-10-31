//
//  MediaDisplayWidget-MediaProvider.swift
//  Physical
//
//  Created by Spencer Hartland on 5/18/26.
//

import Foundation
import PhysicalMediaKit
import WidgetKit
import SwiftUI

extension MediaDisplayWidget {
    struct MediaProvider: AppIntentTimelineProvider {
        typealias Entry = MediaDisplayEntry
        
        private let emptyEntry = Entry(
            date: Date(),
            configuration: SelectMediaIntent(),
            thumbnailKey: "",
        )
        
        func placeholder(in context: Context) -> Entry { return emptyEntry }
        
        func snapshot(for configuration: SelectMediaIntent, in context: Context) async -> Entry {
            guard let media = configuration.media else { return emptyEntry }
            
            let thumbnailKey = thumbnailKey(for: media)
            return Entry(
                date: Date(),
                configuration: configuration,
                thumbnailKey: thumbnailKey,
            )
        }
        
        func timeline(for configuration: SelectMediaIntent, in context: Context) async -> Timeline<Entry> {
            var entries: [Entry] = []
            
            if let media = configuration.media {
                let currentDate = Date()
                let thumbnailKey = thumbnailKey(for: media)
                for hourOffset in 0 ..< 8 {
                    let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                    let entry = Entry(
                        date: entryDate,
                        configuration: configuration,
                        thumbnailKey: thumbnailKey,
                    )
                    entries.append(entry)
                }
            }
            
            return Timeline(entries: entries, policy: .atEnd)
        }
        
        private func thumbnailKey(for media: MediaEntity) -> String {
            switch media.type {
            case .vinylRecord:
                return PhysicalMedia.cacheKey(
                    for: .vinylRecord,
                    artworkURL: media.albumArtworkURL,
                    mediaColor: media.color,
                    scale: 0.150,
                    rotationXY: (0, 0),
                )
            case .compactDisc:
                return PhysicalMedia.cacheKey(
                    for: .compactDisc,
                    artworkURL: media.albumArtworkURL,
                    mediaColor: nil,
                    scale: 0.125,
                    rotationXY: nil,
                )
            case .compactCassette:
                return PhysicalMedia.cacheKey(
                    for: .compactCassette,
                    artworkURL: media.albumArtworkURL,
                    mediaColor: media.color,
                    scale: 0.250,
                    rotationXY: nil,
                )
            }
        }
    }
}
