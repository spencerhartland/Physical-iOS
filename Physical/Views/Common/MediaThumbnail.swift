//
//  MediaThumbnail.swift
//  Physical
//
//  Created by Spencer Hartland on 7/18/23.
//

import SwiftUI
import PhysicalMediaKit

struct MediaThumbnail: View {
    private let favoriteSymbol = "heart.fill"
    
    @Bindable var media: Media
    
    init(for media: Media) {
        self.media = media
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            switch media.type {
            case .vinylRecord:
                PhysicalMedia.vinylRecordThumbnail(
                    media.albumArtworkURL,
                    media.color,
                    rotationXY: (0, -0.08)
                )
            case .compactDisc:
                PhysicalMedia.compactDiscThumbnail(media.albumArtworkURL)
            case .compactCassette:
                PhysicalMedia.compactCassetteThumbnail(media.albumArtworkURL, media.color)
            }
            
            albumInfo
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
        }
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        }
    }
    
    private var albumInfo: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 2) {
                Text(media.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                if media.isFavorite {
                    Image(systemName: favoriteSymbol)
                        .foregroundStyle(.physicalGreen)
                }
            }
            .font(.caption)
            Text(media.artist)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}


// MARK: - Original

//struct MediaThumbnail: View {
//    private let favoriteSymbol = "heart.fill"
//    
//    @Bindable var media: Media
//    
//    init(for media: Media) {
//        self.media = media
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            switch media.type {
//            case .vinylRecord:
//                PhysicalMedia.vinylRecord(
//                    media.albumArtworkURL,
//                    media.color,
//                    rotationXY: (0, -0.08))
//                .aspectRatio(contentMode: .fit)
//            case .compactDisc:
//                PhysicalMedia.compactDisc(
//                    albumArtURL: media.albumArtworkURL,
//                    rotationXY: (0, -0.08))
//                .aspectRatio(contentMode: .fit)
//            case .compactCassette:
//                PhysicalMedia.compactCassette(
//                    albumArtURL: media.albumArtworkURL,
//                    cassetteColor: media.color,
//                    rotationXY: (0, 0))
//                .aspectRatio(contentMode: .fit)
//            }
//            albumInfo
//                .padding(.horizontal, 12)
//                .padding(.bottom, 8)
//        }
//        .background {
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color(UIColor.secondarySystemBackground))
//        }
//    }
//    
//    private var albumInfo: some View {
//        VStack(alignment: .leading) {
//            HStack(spacing: 2) {
//                Text(media.title)
//                    .fontWeight(.semibold)
//                    .foregroundStyle(.primary)
//                    .lineLimit(1)
//                if media.isFavorite {
//                    Image(systemName: favoriteSymbol)
//                        .foregroundStyle(.physicalGreen)
//                }
//            }
//            .font(.caption)
//            Text(media.artist)
//                .font(.caption2)
//                .foregroundStyle(.secondary)
//                .lineLimit(1)
//        }
//    }
//}
