//
//  MediaImageCarousel.swift
//  Physical
//
//  Created by Spencer Hartland on 7/18/23.
//

import SwiftUI
import PhysicalMediaKit

struct MediaImageCarousel: View {
    private let thumbnailSize: CGFloat = 44.0
    
    @Environment(\.screenSize) private var screenSize
    @State private var currentPage: Int = 0
    
    private var mediaType: Media.MediaType
    private var mediaAlbumArtworkURL: URL?
    private var mediaColor: UIColor
    private var mediaImageKeys: [String]
    private var shouldShowModel: Bool
    private var pageIndexOffset: Int { shouldShowModel ? 1 : 0 }
    
    init(for media: Media) {
        self.mediaType = media.type
        self.mediaAlbumArtworkURL = media.albumArtworkURL
        self.mediaColor = media.color
        self.mediaImageKeys = media.imageKeys
        self.shouldShowModel = media.displaysOfficialArtwork
    }
    
    init(for draft: MediaDraft) {
        self.mediaType = draft.type
        self.mediaAlbumArtworkURL = draft.albumArtworkURL
        self.mediaColor = draft.color
        self.mediaImageKeys = draft.imageKeys
        self.shouldShowModel = draft.displaysOfficialArtwork
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 3D Model / user images
            carousel
            
            // Small thumbnails
            if !mediaImageKeys.isEmpty { thumbnailPicker }
        }
        .frame(width: screenSize.width)
    }
    
    private var carousel: some View {
        TabView(selection: $currentPage) {
            if shouldShowModel {
                Tab(value: 0) {
                    Group {
                        switch mediaType {
                        case .vinylRecord:
                            PhysicalMedia.vinylRecord(mediaAlbumArtworkURL, mediaColor)
                        case .compactDisc:
                            PhysicalMedia.compactDisc(mediaAlbumArtworkURL)
                        case .compactCassette:
                            PhysicalMedia.compactCassette(mediaAlbumArtworkURL, mediaColor)
                        }
                    }
                }
            }
            
            ForEach(Array(mediaImageKeys.enumerated()), id: \.offset) { index, key in
                Tab(value: index + pageIndexOffset) {
                    MediaImageView(key: key)
                        .padding()
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .aspectRatio(1.0, contentMode: .fit)
    }
    
    private var thumbnailPicker: some View {
        HStack {
            if shouldShowModel {
                thumbnail(for: 0) {
                    Group {
                        switch mediaType {
                        case .vinylRecord:
                            PhysicalMedia.vinylRecordThumbnail(
                                mediaAlbumArtworkURL,
                                mediaColor,
                                rotationXY: (0, -0.08)
                            )
                        case .compactDisc:
                            PhysicalMedia.compactDiscThumbnail(mediaAlbumArtworkURL)
                        case .compactCassette:
                            PhysicalMedia.compactCassetteThumbnail(mediaAlbumArtworkURL, mediaColor)
                        }
                    }
                }
            }
            
            ForEach(Array(mediaImageKeys.enumerated()), id: \.offset) { index, key in
                thumbnail(for: index + pageIndexOffset) { MediaImageView(key: key) }
            }
        }
    }
    
    private func thumbnail(for page: Int, _ image: @escaping () -> some View) -> some View {
        let width: CGFloat = (page == currentPage) ? thumbnailSize : (thumbnailSize / 2)
        
        return Button {
            withAnimation { currentPage = page }
        } label: {
            ZStack {
                Color(uiColor: .secondarySystemBackground)
                image()
            }
        }
        .frame(width: width, height: thumbnailSize)
        .mask(RoundedRectangle(cornerRadius: 8.0))
        .animation(.default, value: currentPage)
        .padding(.horizontal, page == currentPage ? 8 : 0)
    }
}
