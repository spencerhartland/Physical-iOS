//
//  MediaImageView.swift
//  Physical
//
//  Created by Spencer Hartland on 7/17/23.
//

import SwiftUI
import SwiftData

struct MediaImageView: View {
    private let placeholderAlbumArtSymbolName = "music.note"
    
    let url: URL?
    @Binding var screenSize: CGSize
    private var motion = MotionObserver()
    
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
        ZStack {
            AsyncImage(url: url) { image in
                albumArt(image, size: imageSize)
            } placeholder: {
                mediaImagePlaceholder
            }
        }
        .floating(roll: motion.roll, pitch: motion.pitch, yaw: motion.yaw, screenSize: screenSize)
        .reflection(roll: motion.roll, pitch: motion.pitch, yaw: motion.yaw, screenSize: screenSize)
        .onAppear {
            motion.startUpdates()
        }
    }
    
    private func albumArt(_ image: Image, size: CGFloat) -> some View {
        let roundedRect = RoundedRectangle(cornerRadius: 8)
        return image
            .resizable()
            .clipShape(roundedRect)
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .overlay {
                roundedRect.stroke(lineWidth: 0.5)
                    .foregroundStyle(.secondary)
            }
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
}
