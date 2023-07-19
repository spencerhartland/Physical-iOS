//
//  MediaThumbnail.swift
//  Physical
//
//  Created by Spencer Hartland on 7/18/23.
//

import SwiftUI

struct MediaThumbnail: View {
    private let placeholderAlbumArtSymbolName = "music.note"
    
    let media: Media
    
    init(for media: Media) {
        self.media = media
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            albumArt
            albumInfo
        }
    }
    
    private var albumArt: some View {
        let roundedRect = RoundedRectangle(cornerRadius: 6.0)
        return AsyncImage(url: URL(string: media.images[0])) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(roundedRect)
                .shadow(radius: 2)
                .overlay {
                    roundedRect.stroke(lineWidth: 0.25)
                }
        } placeholder: {
            albumArtPlaceholder
        }
    }
    
    private var albumArtPlaceholder: some View {
        Color(UIColor.secondarySystemGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .aspectRatio(contentMode: .fit)
            .shadow(radius: 2)
            .overlay {
                GeometryReader {
                    Image(systemName: placeholderAlbumArtSymbolName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding($0.size.width * 0.2)
                        .foregroundStyle(.ultraThinMaterial)
                }
            }
    }
    
    private var albumInfo: some View {
        VStack(alignment: .leading) {
            Text(media.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(1)
            Text(media.artist)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
