//
//  MediaWidgetView.swift
//  Physical
//
//  Created by Spencer Hartland on 5/11/26.
//

import SwiftUI
import WidgetKit
import PhysicalMediaKit

struct MediaDisplayWidgetView: View {
    var entry: MediaDisplayEntry
    let widgetURL: URL?
    
    init(entry: MediaDisplayEntry) {
        self.entry = entry
        if let media = entry.configuration.media {
            let mediaID = media.id.uuidString
            self.widgetURL = URL(string: "Physical://Media/\(mediaID)")
        } else {
            self.widgetURL = nil
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            mediaThumbnail
            albumInfo
        }
        .containerBackground(backgroundStyle, for: .widget)
        .widgetURL(widgetURL)
    }
    
    private var mediaThumbnail: some View {
        Group {
            if let thumbnail = PhysicalMedia.cachedThumbnail(for: entry.thumbnailKey) {
                Image(uiImage: thumbnail)
                    .resizable()
                    .widgetAccentedRenderingMode(.fullColor)
                    .aspectRatio(contentMode: .fit)
            } else {
                placeholder
            }
        }
    }
    
    private var albumInfo: some View {
        VStack(alignment: .leading) {
            if let media = entry.configuration.media {
                Text(media.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(media.artist)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            } else {
                EmptyView()
            }
        }
    }
    
    private var placeholder: some View {
        GeometryReader { geometry in
            Rectangle()
                .foregroundStyle(.clear)
                .overlay {
                    Image(systemName: "music.note")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(geometry.size.width / 6)
                        .foregroundStyle(.secondary)
                        .symbolEffect(.pulse)
                }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private var backgroundStyle: some ShapeStyle {
        LinearGradient(
            colors: [
                Color(uiColor: .secondarySystemBackground),
                Color(uiColor: .systemBackground),
            ],
            startPoint: .bottom,
            endPoint: .top,
        )
    }
}

