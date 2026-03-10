//
//  SearchResultListItem.swift
//  Physical
//
//  Created by Spencer Hartland on 7/17/23.
//

import SwiftUI
import MusicKit

struct SearchResultListItem: View {
    private let chevronSymbolName = "chevron.forward"
    
    private let albumArtSize = 56.0
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
                    .foregroundStyle(.primary)
                    .font(.system(size: 16))
                Text(album.artistName)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: chevronSymbolName)
                .foregroundStyle(.secondary)
        }
        .font(.system(size: 14))
    }
}
