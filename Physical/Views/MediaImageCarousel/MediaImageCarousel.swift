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
    var imageKeys: [String]
    var mediaType: Media.MediaType
    
    init(size: CGSize, albumArtworkURL: String?, imageKeys: [String], mediaType: Media.MediaType) {
        self.screenSize = size
        self.albumArtworkURL = albumArtworkURL
        self.imageKeys = imageKeys
        self.mediaType = mediaType
    }
    
    var body: some View {
        TabView {
            if let albumArtworkURL,
               let imageURL = URL(string: albumArtworkURL) {
                switch mediaType {
                case .vinylRecord:
                    PhysicalMedia.vinylRecord(albumArtURL: imageURL, vinylColor: .red, vinylOpacity: 0.9)
                case .compactDisc:
                    PhysicalMedia.compactDisc(albumArtURL: imageURL)
                case .compactCassette:
                    PhysicalMedia.compactCassette(albumArtURL: imageURL, cassetteColor: .init(red: 129/255, green: 41/255, blue: 163/255), cassetteOpacity: 1.0)
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
