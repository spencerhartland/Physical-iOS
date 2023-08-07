//
//  MediaImageCarousel.swift
//  Physical
//
//  Created by Spencer Hartland on 7/18/23.
//

import SwiftUI

struct MediaImageCarousel: View {
    var screenSize: CGSize
    var albumArtworkURL: String?
    var imageKeys: [String]
    
    init(size: CGSize, albumArtworkURL: String?, imageKeys: [String]) {
        self.screenSize = size
        self.albumArtworkURL = albumArtworkURL
        self.imageKeys = imageKeys
    }
    
    var body: some View {
        TabView {
            if let albumArtworkURL {
                MediaImageView(url: albumArtworkURL, size: screenSize)
            }
            ForEach(imageKeys, id: \.self) { key in
                MediaImageView(key: key, size: screenSize)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(width: screenSize.width, height: screenSize.width)
    }
}
