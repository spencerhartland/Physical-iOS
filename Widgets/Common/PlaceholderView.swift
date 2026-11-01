//
//  PlaceholderView.swift
//  PhysicalMediaWidgetExtension
//
//  Created by Spencer Hartland on 11/1/26.
//

import SwiftUI

struct PlaceholderView: View {
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .foregroundStyle(.clear)
                .overlay {
                    Image(systemName: "music.note")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(geometry.size.width / 6)
                        .foregroundStyle(.secondary)
                        .symbolEffect(.pulse)
                }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
