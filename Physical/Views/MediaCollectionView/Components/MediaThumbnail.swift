//
//  MediaThumbnail.swift
//  Physical
//
//  Created by Spencer Hartland on 7/18/23.
//

import SwiftUI

struct MediaThumbnail: View {
    private let placeholderAlbumArtSymbol = "music.note"
    private let compactDiscSymbol = "opticaldisc.fill"
    private let favoriteSymbol = "heart.fill"
    
    let media: Media
    let ornamented: Bool
    
    init(for media: Media, ornamented: Bool = true) {
        self.media = media
        self.ornamented = ornamented
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            albumArt
                .padding([.trailing, .bottom], ornamented ? 8 : 0)
                .overlay {
                    if ornamented { mediaTypeOrnament }
                }
            albumInfo
        }
    }
    
    private var albumArt: some View {
        let roundedRect = RoundedRectangle(cornerRadius: 6.0)
        // TODO: Update to show user images if album artwork is disabled / not there
        return AsyncImage(url: URL(string: media.albumArtworkURL)) { image in
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
    
    private var mediaTypeOrnament: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(.ultraThinMaterial)
                    .frame(width: 32, height: 32)
                    .shadow(radius: 0.5)
                    .overlay {
                        mediaTypeSymbol
                            .resizable()
                            .padding(4)
                            .foregroundStyle(.white)
                    }
            }
        }
    }
    
    private var albumArtPlaceholder: some View {
        Color(UIColor.secondarySystemGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .aspectRatio(contentMode: .fit)
            .shadow(radius: 2)
            .overlay {
                Image(systemName: placeholderAlbumArtSymbol)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .foregroundStyle(.ultraThinMaterial)
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
    
    private var mediaTypeSymbol: Image {
        switch media.type {
        case .vinylRecord:
            return Image(.vinylRecord)
        case .compactDisc:
            return Image(systemName: compactDiscSymbol)
        case .compactCassette:
            return Image(.compactCassette)
        }
    }
}
