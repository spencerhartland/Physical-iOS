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
    private let thumbnailSpacing: CGFloat = 4.0
    
    @Environment(\.screenSize) private var screenSize
    @State private var currentPage: Int = 0
    // Scrub gesture
    @State private var isScrubbing: Bool = false
    @State private var scrubOffset: CGFloat = 0
    @State private var scrubBaseOffset: CGFloat = 0
    @State private var containerCenterX: CGFloat = 0
    
    private var mediaType: Media.MediaType
    private var mediaAlbumArtworkURL: URL?
    private var mediaColor: UIColor
    private var mediaImageKeys: [String]
    private var shouldShowModel: Bool
    private var pageIndexOffset: Int { shouldShowModel ? 1 : 0 }
    private var pages: [Int] {
        let pageCount = mediaImageKeys.count + pageIndexOffset
        var result: [Int] = []
        for i in 0..<pageCount { result.append(i) }
        return result
    }
    
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
            if pages.count > 1 { thumbnailPicker }
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
        GeometryReader { geometry in
            thumbnails
                .offset(x: scrubOffset)
                .frame(width: geometry.size.width)
                .onAppear { containerCenterX = geometry.size.width / 2 }
                .onChange(of: geometry.size.width) { _, newWidth in
                    containerCenterX = newWidth / 2
                }
        }
        .frame(height: thumbnailSize)
        .contentShape(Rectangle())
        .gesture(scrubGesture)
    }
    
    private var thumbnails: some View {
        HStack(spacing: thumbnailSpacing) {
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
    
    private var scrubGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if !isScrubbing {
                    isScrubbing = true
                    scrubBaseOffset = offsetToCenter(page: currentPage)
                }
                scrubOffset = scrubBaseOffset + value.translation.width

                if let page = pageAtCenter(), page != currentPage {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    currentPage = page
                }
            }
            .onEnded { value in
                let wasTap = abs(value.translation.width) < 2
                    && abs(value.translation.height) < 2
                if wasTap, let page = pageTapped(at: value.startLocation) {
                    withAnimation { currentPage = page }
                }
                withAnimation {
                    isScrubbing = false
                    scrubOffset = 0
                }
            }
    }
    
    // MARK: Scrub gesture logic -
    
    /// Offset needed to place the given page's thumbnail at the screen center.
    private func offsetToCenter(page: Int) -> CGFloat {
        let thumbWidth = thumbnailSize / 2
        let totalWidth = CGFloat(pages.count) * thumbWidth
            + CGFloat(pages.count - 1) * thumbnailSpacing
        let centerInStrip = CGFloat(page) * (thumbWidth + thumbnailSpacing) + thumbWidth / 2
        return totalWidth / 2 - centerInStrip
    }

    /// Returns the page whose thumbnail center is closest to the screen center,
    /// given the current `scrubOffset`.
    private func pageAtCenter() -> Int? {
        let thumbWidth = thumbnailSize / 2
        let totalWidth = CGFloat(pages.count) * thumbWidth
            + CGFloat(pages.count - 1) * thumbnailSpacing
        let stripLeft = containerCenterX - totalWidth / 2

        return pages.min(by: { a, b in
            let aCenterX = stripLeft + CGFloat(a) * (thumbWidth + thumbnailSpacing)
                + thumbWidth / 2 + scrubOffset
            let bCenterX = stripLeft + CGFloat(b) * (thumbWidth + thumbnailSpacing)
                + thumbWidth / 2 + scrubOffset
            return abs(aCenterX - containerCenterX) < abs(bCenterX - containerCenterX)
        })
    }

    /// Returns the page whose thumbnail contains the given point (in container coords).
    /// Uses the non-scrub layout since taps occur before scrubbing starts.
    private func pageTapped(at point: CGPoint) -> Int? {
        // In the non-scrub layout, the focused thumbnail is full-size with padding.
        // Compute each thumbnail's horizontal extent in the centered HStack.
        let focusedWidth = thumbnailSize + 16 // width + horizontal padding
        let normalWidth = thumbnailSize / 2
        let totalWidth = focusedWidth + normalWidth * CGFloat(pages.count - 1)
            + thumbnailSpacing * CGFloat(pages.count - 1)
        var x = containerCenterX - totalWidth / 2

        for page in pages {
            let w = page == currentPage ? focusedWidth : normalWidth
            if point.x >= x && point.x <= x + w {
                return page
            }
            x += w + thumbnailSpacing
        }
        return nil
    }
    
    private func thumbnail(for page: Int, _ image: @escaping () -> some View) -> some View {
        let isFocused = page == currentPage && !isScrubbing
        let width: CGFloat = isFocused ? thumbnailSize : (thumbnailSize / 2)
        
        return ZStack {
            Color(uiColor: .secondarySystemBackground)
            image()
        }
        .frame(width: width, height: thumbnailSize)
        .mask(RoundedRectangle(cornerRadius: 8.0))
        .animation(.default, value: currentPage)
        .animation(.default, value: isScrubbing)
        .padding(.horizontal, isFocused ? 8 : 0)
    }
}

fileprivate struct ThumbnailFramePreference: PreferenceKey {
    static var defaultValue: [Int: CGRect] = [:]
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}
