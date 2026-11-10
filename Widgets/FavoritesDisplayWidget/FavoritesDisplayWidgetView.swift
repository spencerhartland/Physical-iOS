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
            if entry.thumbnails.isEmpty {
                PlaceholderView()
            } else {
                CoverFlowView(thumbnails: entry.thumbnails)
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
    
    private var backgroundStyle: some ShapeStyle {
        Color(uiColor: .systemBackground).gradient
    }
}

extension FavoritesDisplayWidgetView {
    struct CoverFlowView: View {
        let thumbnails: [UIImage]
        
        var body: some View {
            let enumeratedThumbnails = Array(thumbnails.enumerated())
            
            GeometryReader { proxy in
                let width: CGFloat = proxy.size.width
                let itemWidth: CGFloat = width * 0.65
                let remainingWidth: CGFloat = width - itemWidth
                
                ZStack(alignment: .leading) {
                    ForEach(enumeratedThumbnails, id: \.offset) { index, thumbnail in
                        let brightness: CGFloat = -(CGFloat(index) * 0.025)
                        let offset: CGFloat = {
                            thumbnails.count < 2
                            ? 0
                            : (remainingWidth / CGFloat(thumbnails.count - 1)) * CGFloat(index)
                        }()
                        
                        Image(uiImage: thumbnail)
                            .resizable()
                            .widgetAccentedRenderingMode(.fullColor)
                            .aspectRatio(contentMode: .fit)
                            .brightness(brightness)
                            .shadow(radius: 1)
                            .frame(maxWidth: itemWidth)
                            .offset(x: offset)
                            .zIndex(Double(-index))
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .leading)
            }
        }
    }
}
