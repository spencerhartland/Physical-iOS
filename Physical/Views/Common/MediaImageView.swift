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
    
    @State private var image: UIImage? = nil
    
    let key: String
    
    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .aspectRatio(contentMode: .fill)
            } else {
                PlaceholderView()
            }
        }
        .task {
            do {
                image = try await ImageManager.shared.retrieveImage(withKey: key)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
