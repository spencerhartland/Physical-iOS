//
//  MediaImageView.swift
//  Physical
//
//  Created by Spencer Hartland on 7/17/23.
//

import SwiftUI

struct MediaImageView: View {
    private let placeholderAlbumArtSymbolName = "music.note"
    
    let url: URL?
    @Binding var screenSize: CGSize
    @State private var offset: CGSize = .zero
    
    init(url: String, size: Binding<CGSize>) {
        self.url = URL(string: url)
        self._screenSize = size
    }
    
    init(url: URL?, size: Binding<CGSize>) {
        self.url = url
        self._screenSize = size
    }
    
    var body: some View {
        let imageSize = screenSize.width * 0.85
        let roundedRect = RoundedRectangle(cornerRadius: 8)
        ZStack {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .clipShape(roundedRect)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageSize, height: imageSize)
                    .overlay {
                        roundedRect.stroke(lineWidth: 0.5)
                            .foregroundStyle(.secondary)
                    }
            } placeholder: {
                mediaImagePlaceholder
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .rotation3DEffect(calculateAngle(onXAxis: true), axis: (x: -1, y: 0, z: 0))
        .rotation3DEffect(calculateAngle(onXAxis: false), axis: (x: 0, y: 1, z: 0))
        .reflection(offset: $offset, screenSize: screenSize)
        .gesture(
            DragGesture()
                .onChanged({ value in
                    offset = value.translation
                })
                .onEnded({ _ in
                    withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.32, blendDuration: 0.32)) {
                        offset = .zero
                    }
                })
        )
    }
    
    private var mediaImagePlaceholder: some View {
        let imageSize = screenSize.width * 0.85
        return Color(UIColor.secondarySystemGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .aspectRatio(contentMode: .fit)
            .frame(width: imageSize, height: imageSize)
            .overlay {
                VStack {
                    Image(systemName: placeholderAlbumArtSymbolName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(imageSize * 0.2)
                        .foregroundStyle(.ultraThinMaterial)
                }
            }
    }
    
    private func calculateAngle(onXAxis: Bool) -> Angle {
        let progress = (onXAxis ? offset.height : offset.width) / (onXAxis ? screenSize.height : screenSize.width)
        return .init(degrees: progress * 10)
    }
}