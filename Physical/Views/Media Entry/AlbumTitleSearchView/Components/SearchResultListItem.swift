//
//  SearchResultListItem.swift
//  Physical
//
//  Created by Spencer Hartland on 7/17/23.
//

import SwiftUI
import MusicKit

struct SearchResultListItem: View {
    private let albumArtSize = 44.0
    private let albumArtCornerRadius = 4.0
    
    let album: Album
    
    init(for album: Album) {
        self.album = album
    }
    
    var body: some View {
        HStack(spacing: 16) {
            AlbumArtView(album.artwork, size: albumArtSize, cornerRadius: albumArtCornerRadius)
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
}
