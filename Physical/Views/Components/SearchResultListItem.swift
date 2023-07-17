//
//  SearchResultListItem.swift
//  Physical
//
//  Created by Spencer Hartland on 7/17/23.
//

import SwiftUI
import MusicKit

struct SearchResultListItem: View {
    let album: Album
    
    init(for album: Album) {
        self.album = album
    }
    
    var body: some View {
        HStack(spacing: 16) {
            AlbumArt(artwork: album.artwork)
            VStack(alignment: .leading) {
                Text(album.title)
                    .lineLimit(1)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(album.artistName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private struct AlbumArt: View {
        private let roundedRect = RoundedRectangle(cornerRadius: 4.0)
        private let noAlbumArtSymbol = "music.note"
        
        let artwork: Artwork?
        
        var body: some View {
            if let artwork = artwork {
                ArtworkImage(artwork, width: 44, height: 44)
                    .clipShape(roundedRect)
                    .shadow(radius: 2)
                    .overlay {
                        roundedRect.stroke(lineWidth: 0.25)
                    }
            } else {
                roundedRect
                    .foregroundStyle(.secondary)
                    .overlay {
                        Image(systemName: noAlbumArtSymbol)
                            .resizable()
                            .padding(4)
                            .foregroundStyle(.primary)
                    }
            }
        }
    }
}
