//
//  BarcodeSearchResultSheet.swift
//  Physical
//
//  Created by Spencer Hartland on 12/14/23.
//

import SwiftUI
import MusicKit

struct BarcodeSearchResultView: View {
    private let searchResultCaptionText = "Tap to continue"
    
    let album: Album
    
    init(for result: Album) {
        self.album = result
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 8) {
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
                Spacer()
            }
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundStyle(.thickMaterial)
            }
            Text(searchResultCaptionText)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
    }
    
    // MARK: - Album art
    
    private struct AlbumArt: View {
        private let roundedRect = RoundedRectangle(cornerRadius: 8.0)
        private let noAlbumArtSymbol = "music.note"
        
        @Environment(\.screenSize) private var screenSize
        
        let artwork: Artwork?
        
        var body: some View {
            if let artwork = artwork {
                let artworkSize = screenSize.width / 6
                ArtworkImage(artwork, width: artworkSize, height: artworkSize)
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
