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
    let entry: MediaDisplayEntry
    
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading) {
                switch entry.content {
                case .sample:
                    placeholderArtwork
                    albumInfo(title: "Album Title", artist: "Artist")
                        .redacted(reason: .placeholder)
                case .media(let media):
                    mediaThumbnail
                    albumInfo(title: media.title, artist: media.artist)
                case .noFavorites:
                    PlaceholderView()
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .foregroundStyle(foregroundStyle)
        }
        .containerBackground(backgroundStyle, for: .widget)
        .widgetURL(widgetURL)
    }
    
    private var media: MediaEntity? {
        switch entry.content {
        case .media(let media): media
        case .sample, .noFavorites: nil
        }
    }
    
    private var widgetURL: URL? {
        media.flatMap { URL(string: "Physical://Media/\($0.id.uuidString)") }
    }
    
    private var mediaThumbnail: some View {
        Group {
            if let thumbnail = entry.thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .widgetAccentedRenderingMode(.fullColor)
                    .aspectRatio(contentMode: .fit)
            } else {
                placeholderArtwork
            }
        }
    }
    
    private func albumInfo(title: String, artist: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(1)
            Text(artist)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
    
    private var placeholderArtwork: some View {
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
    
    private var foregroundStyle: some ShapeStyle {
        if let bgColor = media?.dominantColor {
            ContrastingStyle(background: bgColor)
        } else {
            ContrastingStyle(background: Color(uiColor: .systemBackground))
        }
    }
    
    private var backgroundStyle: some ShapeStyle {
        if let bgColor = media?.dominantColor {
            bgColor.gradient
        } else {
            Color(uiColor: .systemBackground).gradient
        }
    }
}
