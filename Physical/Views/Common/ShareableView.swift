//
//  ShareableView.swift
//  Physical
//
//  Created by Spencer Hartland on 2/10/26.
//

import SwiftUI
import PhysicalMediaKit

@MainActor struct Shareable {
    static func image(
        for media: Media,
        with label: String,
        rarity: Rarity
    ) async -> UIImage? {
        var thumbnail: UIImage? = nil
        
        switch media.type {
        case .vinylRecord:
            thumbnail = await PhysicalMedia.vinylRecordThumbnailImage(
                media.albumArtworkURL,
                media.color)
        case .compactDisc:
            thumbnail = await PhysicalMedia.compactDiscThumbnailImage(media.albumArtworkURL)
        case .compactCassette:
            thumbnail = await PhysicalMedia.compactCassetteThumbnailImage(
                media.albumArtworkURL,
                media.color)
        }
        
        let shareableView = ShareableView(
            for: media,
            label: label,
            rarity: rarity,
            thumbnail: thumbnail)
        
        let renderer = ImageRenderer(content: shareableView)
        renderer.scale = UIScreen.main.scale
        renderer.proposedSize = ProposedViewSize(
            width: UIScreen.main.bounds.width,
            height: nil
        )
        
        return renderer.uiImage
    }
}

internal struct ShareableView: View {
    private static let navigationTitle = "Share"
    private static let appName = "Physical"
    private static let defaultLabelString = "From my collection"
    
    @State private var rarity: Rarity
    @State private var shareableImage: UIImage?
    
    private var media: Media
    private var label: String
    private var thumbnail: UIImage?
    private var contentWidth: CGFloat
    
    init(
        for media: Media,
        label: String = ShareableView.defaultLabelString,
        rarity: Rarity = .common,
        thumbnail: UIImage? = nil,
        contentWidth: CGFloat = UIScreen.main.bounds.width
    ) {
        self.media = media
        self.label = label
        self.rarity = rarity
        self.thumbnail = thumbnail
        self.contentWidth = contentWidth
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            if thumbnail == nil { rarityMenu }
            cardContent
            shareButton
        }
        .padding(32)
        .background(Color(.systemBackground))
        .fixedSize(horizontal: false, vertical: true)
        .navigationTitle(ShareableView.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: rarity) {
            guard thumbnail == nil else { return }
            shareableImage = nil
            shareableImage = await Shareable.image(for: media, with: label, rarity: rarity)
        }
    }
    
    private var rarityMenu: some View {
        Menu {
            ForEach(Rarity.allCases, id: \.self) { rarity in
                menuButton(for: rarity)
            }
        } label: {
            HStack(alignment: .center) {
                Text("Rarity (\(self.rarity.rawValue.capitalized))")
                Image(systemName: "chevron.down")
            }
            .fontWeight(.medium)
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .menuButtonStyle()
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading) {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: contentWidth, height: contentWidth)
            } else {
                switch media.type {
                case .vinylRecord:
                    PhysicalMedia.vinylRecordThumbnail(
                        media.albumArtworkURL,
                        media.color,
                        rotationXY: (0, -0.08))
                case .compactDisc:
                    PhysicalMedia.compactDiscThumbnail(media.albumArtworkURL)
                case .compactCassette:
                    PhysicalMedia.compactCassetteThumbnail(media.albumArtworkURL, media.color)
                }
            }
            Text(label)
                .font(.system(size: 18))
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
            Text(media.title)
                .font(.system(size: 24))
                .fontWeight(.bold)
            Text(media.artist)
                .font(.system(size: 20))
                .fontWeight(.semibold)
            Text("\(media.rawType) · \(media.genre) · \(media.releaseDate, format: .dateTime.year())")
                .font(.system(size: 16))
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
        .padding(32)
        .foregroundStyle(.white)
        .colorCode(for: rarity)
    }
    
    private var shareButton: some View {
        Group {
            if thumbnail != nil {
                Label {
                    Text(ShareableView.appName)
                        .font(.title2)
                } icon: {
                    Image(.physicalIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 32)
                }
            } else {
                Group {
                    if let shareableImage {
                        let image = Image(uiImage: shareableImage)
                        ShareLink(item: image, preview: SharePreview(media.title, image: image)) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .fontWeight(.semibold)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .prominentButtonStyle()
                        .tint(.physicalGreen)
                    } else {
                        ProgressView()
                    }
                }
            }
        }
        .fontWeight(.medium)
    }
    
    private func menuButton(for rarity: Rarity) -> some View {
        let label = Label(rarity.rawValue.capitalized, systemImage: "checkmark")
        
        return Button {
            self.rarity = rarity
        } label: {
            if self.rarity == rarity {
                label
                    .labelStyle(.titleAndIcon)
            } else {
                label
                    .labelStyle(.titleOnly)
            }
        }
    }
}

extension View {
    @ViewBuilder func menuButtonStyle() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glass)
        } else {
            self
                .buttonStyle(.bordered)
                .foregroundStyle(.primary)
        }
    }
}
