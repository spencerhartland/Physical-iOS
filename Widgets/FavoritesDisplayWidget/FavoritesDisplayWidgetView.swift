//
//  FavoritesDisplayWidgetView.swift
//  Physical
//
//  Created by Spencer Hartland on 5/20/26.
//

import Foundation
import OSLog
import PhysicalMediaKit
import SwiftUI
import WidgetKit

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
        Color(uiColor: .systemBackground).gradient
    }
}

extension FavoritesDisplayWidgetView {
    struct CoverFlowView: View {
        let thumbnailKeys: [String]
        
        var body: some View {
            let enumeratedThumbnailKeys = Array(thumbnailKeys.enumerated())
            
            GeometryReader { proxy in
                let width: CGFloat = proxy.size.width
                let itemWidth: CGFloat = width * 0.65
                let remainingWidth: CGFloat = width - itemWidth
                
                ZStack(alignment: .leading) {
                    ForEach(enumeratedThumbnailKeys, id: \.offset) { index, key in
                        let offset: CGFloat = {
                            (remainingWidth / CGFloat(thumbnailKeys.count - 1)) * CGFloat(index)
                        }()
                        
                        coverFlowItem(for: key, at: index)
                            .frame(maxWidth: itemWidth)
                            .offset(x: offset)
                            .zIndex(Double(-index))
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .leading)
            }
        }
        
        private func coverFlowItem(for key: String, at index: Int) -> some View {
            let brightness: CGFloat = -(CGFloat(index) * 0.025)
            
            return Group {
                if let image = PhysicalMedia.cachedThumbnail(for: key) {
                    Image(uiImage: image)
                        .resizable()
                        .widgetAccentedRenderingMode(.fullColor)
                        .aspectRatio(contentMode: .fit)
                        .brightness(brightness)
                        .shadow(radius: 1)
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
