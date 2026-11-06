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
            date: .now,
            configuration: SelectMediaIntent(),
            thumbnail: nil,
            dominantColor: nil
        )
        
        func placeholder(in context: Context) -> Entry { return emptyEntry }
        
        func snapshot(for configuration: SelectMediaIntent, in context: Context) async -> Entry {
            guard let media = configuration.media else { return emptyEntry }
            
            let key = thumbnailKey(for: media)
            let thumbnail = PhysicalMedia.cachedThumbnail(for: key)
            
            return Entry(
                date: .now, 
                configuration: configuration,
                thumbnail: thumbnail,
                dominantColor: media.dominantColor
            )
        }
        
        func timeline(for configuration: SelectMediaIntent, in context: Context) async -> Timeline<Entry> {
            var entries: [Entry] = []
            
            if let media = configuration.media {
                let date = Date()
                let key = thumbnailKey(for: media)
                let thumbnail = PhysicalMedia.cachedThumbnail(for: key)
                for hourOffset in 0 ..< 8 {
                    let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: date)!
                    let entry = Entry(
                        date: entryDate,
                        configuration: configuration,
                        thumbnail: thumbnail,
                        dominantColor: media.dominantColor
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
