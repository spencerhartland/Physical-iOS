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
    
    @State private var image: UIImage? = nil
    
    init(url: String) {
        self.key = nil
        self.url = URL(string: url)
    }
    
    init(url: URL?) {
        self.key = nil
        self.url = url
    }
    
    init(key: String) {
        self.key = key
        self.url = nil
    }
    
    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .aspectRatio(contentMode: .fill)
            } else {
                mediaImagePlaceholder
            }
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
    
    private var mediaImagePlaceholder: some View {
        return Color(UIColor.secondarySystemGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .aspectRatio(contentMode: .fill)
            .overlay {
                VStack {
                    Image(systemName: placeholderAlbumArtSymbolName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                        .foregroundStyle(.ultraThinMaterial)
                }
            }
    }
}
