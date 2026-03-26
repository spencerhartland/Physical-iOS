//
//  PlaceholderView.swift
//  Physical
//
//  Created by Spencer Hartland on 3/26/26.
//

import SwiftUI

internal struct PlaceholderView: View {
    private let placeholderSymbolName = "music.note"
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .foregroundStyle(.clear)
                .overlay {
                    Image(systemName: placeholderSymbolName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(geometry.size.width / 6)
                        .foregroundStyle(.secondary)
                }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
