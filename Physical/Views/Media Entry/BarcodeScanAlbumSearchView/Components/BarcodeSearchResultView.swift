//
//  BarcodeSearchResultSheet.swift
//  Physical
//
//  Created by Spencer Hartland on 12/14/23.
//

import SwiftUI
import MusicKit

struct BarcodeSearchResultView: View {
    private let albumTitlePlaceholderValue = "Placeholder album title"
    private let albumArtistPlaceholderValue = "Placeholder album artist"
    private let interactionSymbolName = "chevron.forward"
    private let noResultsTitleText = "No results"
    private let noResultsDescriptionText = "Tap to add this media manually"
    
    @Environment(\.screenSize) private var screenSize
    
    let album: Album?
    @Binding private var searchReturnedNoResults: Bool
    
    init(for result: Album?, completionFlag: Binding<Bool>) {
        self.album = result
        self._searchReturnedNoResults = completionFlag
    }
    
    var body: some View {
        HStack(spacing: 8) {
            AlbumArtView(album?.artwork ?? nil, size: screenSize.width / 6)
            VStack(alignment: .leading) {
                Text(searchReturnedNoResults ? noResultsTitleText : album?.title ?? albumTitlePlaceholderValue)
                    .lineLimit(1)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(searchReturnedNoResults ? noResultsDescriptionText : album?.artistName ?? albumArtistPlaceholderValue)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .redacted(reason: (album == nil && !searchReturnedNoResults) ? .placeholder : [])
            Spacer()
            Image(systemName: interactionSymbolName)
                .foregroundStyle(.tertiary)
                .padding(8)
        }
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: 16.0)
                .foregroundStyle(Color(UIColor.secondarySystemBackground))
        }
    }
}
