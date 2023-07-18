//
//  MediaImageCarousel.swift
//  Physical
//
//  Created by Spencer Hartland on 7/18/23.
//

import SwiftUI

struct MediaImageCarousel: View {
    @Binding var screenSize: CGSize
    @Binding var imageURLStrings: [String]
    
    init(size: Binding<CGSize>, imageURLStrings: Binding<[String]>) {
        self._screenSize = size
        self._imageURLStrings = imageURLStrings
    }
    
    var body: some View {
        TabView {
            ForEach(imageURLStrings, id: \.self) { urlString in
                MediaImageView(url: urlString, size: $screenSize)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(width: screenSize.width, height: screenSize.width)
    }
}
