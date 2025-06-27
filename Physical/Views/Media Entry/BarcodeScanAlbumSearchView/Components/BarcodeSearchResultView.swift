//
//  BarcodeSearchResultSheet.swift
//  Physical
//
//  Created by Spencer Hartland on 12/14/23.
//

import SwiftUI
import MusicKit

struct BarcodeSearchResultView: View {
    @Environment(\.screenSize) private var screenSize
    
    let album: Album?
    @Binding private var searchReturnedNoResults: Bool
    
    init(for result: Album?, completionFlag: Binding<Bool>) {
        self.album = result
        self._searchReturnedNoResults = completionFlag
    }
    
    var body: some View {
        HStack(spacing: 8) {
            AlbumArtView(album?.artwork ?? nil, size: screenSize.width / 8, cornerRadius: 10)
            VStack(alignment: .leading) {
                Text(searchReturnedNoResults ? "No results" : album?.title ?? "Album title")
                    .lineLimit(1)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(searchReturnedNoResults ? "Tap to add this media manually" : album?.artistName ?? "Album artist")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .redacted(reason: (album == nil && !searchReturnedNoResults) ? .placeholder : [])
            Spacer()
            Image(systemName: "chevron.forward")
                .foregroundStyle(.tertiary)
                .padding(8)
        }
        .padding(.vertical, 16)
        .padding(.leading, 32)
        .padding(.trailing, 16)
        .background {
            if #available(iOS 26.0, *) {
                Capsule()
                    .fill(Color.clear)
                    .glassEffect()
            } else {
                Capsule()
                    .fill(.regularMaterial)
            }
        }
    }
}
