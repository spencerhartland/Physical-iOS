//
//  VariableBlurImageBackgroundViewModifier.swift
//  Physical
//
//  Created by Spencer Hartland on 8/15/23.
//

import SwiftUI

struct VariableBlurImageBackgroundView: ViewModifier {
    let urlString: String
    
    func body(content: Content) -> some View {
        if let url = URL(string: urlString) {
            content
                .background {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 6, opaque: true)
                    } placeholder: {
                        Color.red
                    }
                    .overlay {
                        Rectangle()
                            .foregroundStyle(.regularMaterial)
                            .mask {
                                LinearGradient(
                                    stops: [
                                        .init(color: .white, location: 0.25),
                                        .init(color: .clear, location: 0.85)
                                    ],
                                    startPoint: .bottom,
                                    endPoint: .top)
                            }
                    }
                    .ignoresSafeArea()
                }
        } else {
            content
        }
    }
}

extension View {
    func variableBlurBackground(_ imageURLString: String) -> some View {
        return modifier(VariableBlurImageBackgroundView(urlString: imageURLString))
    }
}

#Preview {
    let albumArtURLString = "https://m.media-amazon.com/images/I/51clQVJViDL._UXNaN_FMjpg_QL85_.jpg"
    return List {
        Section {
            Text("Item 1")
            Text("Item 2")
            Text("Item 3")
        }
    }
    .scrollContentBackground(.hidden)
    .variableBlurBackground(albumArtURLString)
}
