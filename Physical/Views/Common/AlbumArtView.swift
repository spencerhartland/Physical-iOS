//
//  AlbumArtView.swift
//  Physical
//
//  Created by Spencer Hartland on 12/16/23.
//

import SwiftUI
import MusicKit

struct AlbumArtView: View {
    private let noAlbumArtSymbol = "music.note"
    
    init(_ artwork: Artwork?, size: CGFloat, cornerRadius: CGFloat = 8.0) {
        self.artwork = artwork
        self.artworkSize = size
        self.artworkCornerRadius = cornerRadius
    }
    
    let artwork: Artwork?
    let artworkSize: CGFloat
    let artworkCornerRadius: CGFloat
    
    var body: some View {
        let roundedRect = RoundedRectangle(cornerRadius: artworkCornerRadius)
        
        if let artwork = artwork {
            ArtworkImage(artwork, width: artworkSize, height: artworkSize)
                .clipShape(roundedRect)
                .shadow(radius: 2)
                .overlay {
                    roundedRect.stroke(lineWidth: 0.25)
                }
        } else {
            roundedRect
                .frame(width: artworkSize, height: artworkSize)
                .foregroundStyle(.placeholder)
                .overlay {
                    Image(systemName: noAlbumArtSymbol)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                        .foregroundStyle(Color(UIColor.systemBackground))
                }
        }
    }
}
