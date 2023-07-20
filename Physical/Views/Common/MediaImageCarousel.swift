//
//  MediaImageCarousel.swift
//  Physical
//
//  Created by Spencer Hartland on 7/18/23.
//

import SwiftUI

struct MediaImageCarousel: View {
    var screenSize: CGSize
    var imageURLStrings: [String]
    
    init(size: CGSize, imageURLStrings: [String]) {
        self.screenSize = size
        self.imageURLStrings = imageURLStrings
    }
    
    var body: some View {
        TabView {
            ForEach(imageURLStrings, id: \.self) { urlString in
                MediaImageView(url: urlString, size: screenSize)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(width: screenSize.width, height: screenSize.width)
    }
}
