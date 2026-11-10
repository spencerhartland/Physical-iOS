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
        
        func placeholder(in context: Context) -> Entry {
            Entry(date: .now, content: .sample, thumbnail: nil)
        }
        
        func snapshot(for configuration: SelectMediaIntent, in context: Context) async -> Entry {
            await entry(for: configuration, at: .now)
        }
        
        func timeline(for configuration: SelectMediaIntent, in context: Context) async -> Timeline<Entry> {
            let date = Date.now
            let entry = await entry(for: configuration, at: date)
            let refreshDate = Calendar.current.date(byAdding: .hour, value: 8, to: date)!
            return Timeline(entries: [entry], policy: .after(refreshDate))
        }
        
        private func entry(for configuration: SelectMediaIntent, at date: Date) async -> Entry {
            guard let media = await resolveMedia(for: configuration) else {
                return Entry(date: date, content: .noFavorites, thumbnail: nil)
            }
            let thumbnail = PhysicalMedia.cachedThumbnail(for: thumbnailKey(for: media))
            return Entry(date: date, content: .media(media), thumbnail: thumbnail)
        }
        
        private func resolveMedia(for configuration: SelectMediaIntent) async -> MediaEntity? {
            let query = MediaQuery()
            guard let selected = configuration.media else {
                return await query.defaultResult()
            }
            return try? await query.entities(for: [selected.id]).first
        }
        
        private func thumbnailKey(for media: MediaEntity) -> String {
            switch media.type {
            case .vinylRecord:
                return PhysicalMedia.cacheKey(
                    for: .vinylRecord,
                    artworkURL: media.albumArtworkURL,
                    coverColor: media.coverColor,
                    mediaColor: media.mediaColor,
                    scale: 0.150,
                    rotationXY: (0, 0),
                )
            case .compactDisc:
                return PhysicalMedia.cacheKey(
                    for: .compactDisc,
                    artworkURL: media.albumArtworkURL,
                    coverColor: media.coverColor,
                    mediaColor: nil,
                    scale: 0.125,
                    rotationXY: nil,
                )
            case .compactCassette:
                return PhysicalMedia.cacheKey(
                    for: .compactCassette,
                    artworkURL: media.albumArtworkURL,
                    coverColor: media.coverColor,
                    mediaColor: media.mediaColor,
                    scale: 0.250,
                    rotationXY: nil,
                )
            }
        }
    }
}
