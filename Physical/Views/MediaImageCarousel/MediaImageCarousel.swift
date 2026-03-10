//
//  MediaImageCarousel.swift
//  Physical
//
//  Created by Spencer Hartland on 7/18/23.
//

import SwiftUI
import PhysicalMediaKit

struct MediaImageCarousel: View {
    @Environment(\.screenSize) private var screenSize
    
    var type: Media.MediaType
    var artworkURL: URL?
    var color: UIColor
    
    init(for type: Media.MediaType, with artworkURL: URL?, and color: UIColor) {
        self.type = type
        self.artworkURL = artworkURL
        self.color = color
    }
    
    var body: some View {
        Group {
            switch type {
            case .vinylRecord:
                PhysicalMedia.vinylRecord(artworkURL, color)
            case .compactDisc:
                PhysicalMedia.compactDisc(artworkURL)
            case .compactCassette:
                PhysicalMedia.compactCassette(artworkURL, color)
            }
        }
        .frame(width: screenSize.width, height: screenSize.width)
    }
}
