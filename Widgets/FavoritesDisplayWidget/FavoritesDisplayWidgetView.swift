//
//  FavoritesDisplayWidgetView.swift
//  Physical
//
//  Created by Spencer Hartland on 5/20/26.
//

import SwiftUI
import WidgetKit
import PhysicalMediaKit

struct FavoritesDisplayWidgetView: View {
    var entry: FavoritesDisplayEntry
    let widgetURL: URL?
    
    init(entry: FavoritesDisplayEntry) {
        self.entry = entry
        if let media = entry.favorites.first {
            let mediaID = media.id.uuidString
            self.widgetURL = URL(string: "Physical://Media/\(mediaID)")
        } else {
            self.widgetURL = nil
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if !entry.thumbnailKeys.isEmpty {
                CoverFlowView(thumbnailKeys: entry.thumbnailKeys)
            } else {
                placeholder
            }
            albumInfo
        }
        .containerBackground(backgroundStyle, for: .widget)
        .widgetURL(widgetURL)
    }
    
    private var albumInfo: some View {
        VStack(alignment: .leading) {
            if let media = entry.favorites.first {
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

extension FavoritesDisplayWidgetView {
    struct CoverFlowView: View {
        let thumbnailKeys: [String]
        
        var body: some View {
            let enumeratedThumbnailKeys = Array(thumbnailKeys.enumerated())
            
            ZStack {
                ForEach(enumeratedThumbnailKeys, id: \.offset) { index, key in
                    coverFlowItem(for: key, at: index)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        
        private func coverFlowItem(for key: String, at index: Int) -> some View {
            let imageOffset: CGFloat = {
                if index == 0 { return 0 }
                return CGFloat(index) * 32
            }()
            
            return Group {
                if let image = PhysicalMedia.cachedThumbnail(for: key) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 85)
                        .offset(x: imageOffset)
                        .brightness(Double(index) * 0.05)
                        .shadow(radius: 1)
                        .zIndex(Double(-index))
                } else {
                    placeholder
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
    }
}

