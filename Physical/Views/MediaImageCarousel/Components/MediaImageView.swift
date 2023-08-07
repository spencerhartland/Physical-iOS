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
    
    private let key: String?
    private let url: URL?
    private var screenSize: CGSize
    private var motion = Motion()
    
    @State private var image: UIImage? = nil
    
    init(url: String, size: CGSize) {
        self.key = nil
        self.url = URL(string: url)
        self.screenSize = size
    }
    
    init(url: URL?, size: CGSize) {
        self.key = nil
        self.url = url
        self.screenSize = size
    }
    
    init(key: String, size: CGSize) {
        self.key = key
        self.url = nil
        self.screenSize = size
    }
    
    var body: some View {
        let imageSize = screenSize.width * 0.85
        ZStack {
            if let image {
                albumArt(size: imageSize) {
                    Image(uiImage: image)
                }
            } else {
                mediaImagePlaceholder
            }
        }
        .floating(roll: motion.roll, pitch: motion.pitch, yaw: motion.yaw, screenSize: screenSize)
        .reflection(roll: motion.roll, pitch: motion.pitch, yaw: motion.yaw, screenSize: screenSize)
        .onAppear {
            motion.startUpdates()
        }
        .task {
            do {
                if let url {
                    image = try await ImageManager.shared.fetchImage(url: url)
                } else if let key {
                    image = try await ImageManager.shared.retrieveImage(withKey: key)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func albumArt(size: CGFloat, @ViewBuilder _ image: () -> Image) -> some View {
        let roundedRect = RoundedRectangle(cornerRadius: 8)
        return image()
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
