//
//  MediaImageCarousel.swift
//  Physical
//
//  Created by Spencer Hartland on 7/18/23.
//

import SwiftUI
import PhysicalMediaKit

struct MediaImageCarousel: View {
    var screenSize: CGSize
    var albumArtworkURL: String?
    var mediaColor: Color
    var imageKeys: [String]
    var mediaType: Media.MediaType
    
    init(
        size: CGSize,
        albumArtworkURL: String?,
        mediaColor: UIColor,
        imageKeys: [String],
        mediaType: Media.MediaType
    ) {
        self.screenSize = size
        self.albumArtworkURL = albumArtworkURL
        self.mediaColor = Color(mediaColor)
        self.imageKeys = imageKeys
        self.mediaType = mediaType
    }
    
    var body: some View {
        TabView {
            if let albumArtworkURL, let imageURL = URL(string: albumArtworkURL) {
                switch mediaType {
                case .vinylRecord:
                    PhysicalMedia.vinylRecord(albumArtURL: imageURL, vinylColor: mediaColor)
                case .compactDisc:
                    PhysicalMedia.compactDisc(albumArtURL: imageURL)
                case .compactCassette:
                    PhysicalMedia.compactCassette(albumArtURL: imageURL, cassetteColor: mediaColor)
                }
            }
            ForEach(imageKeys, id: \.self) { key in
                MediaImageView(key: key, size: screenSize)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(width: screenSize.width, height: screenSize.width)
    }
}
