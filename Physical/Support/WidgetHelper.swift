//
//  WidgetHelper.swift
//  Physical
//
//  Created by Spencer Hartland on 10/29/26.
//

import Foundation
import PhysicalMediaKit
import SwiftData
import UIKit
import WidgetKit

actor WidgetHelper {
    enum WidgetKind: String {
        case mediaDisplay = "com.spencerhartland.Physical.MediaDisplayWidget"
        case favoritesDisplay = "com.spencerhartland.Physical.FavoritesDisplayWidget"
    }
    
    nonisolated static func reloadTimelines(ofKind kind: WidgetKind) {
        WidgetCenter.shared.reloadTimelines(ofKind: kind.rawValue)
    }
    
    nonisolated static func reloadTimelines() {
        reloadTimelines(ofKind: .favoritesDisplay)
        reloadTimelines(ofKind: .mediaDisplay)
    }
    
    static func prepareFavoritesForWidget(_ favorites: [Media]) async {
        for favorite in favorites {
            await renderThumbnailsForFavorite(favorite)
            
            if let artworkURL = favorite.albumArtworkURL,
               let artwork = await PhysicalMedia.albumArtwork(from: artworkURL) {
                let colors = await DominantColorsCalculator.dominantColors(in: artwork)
                favorite.dominantColors = colors
            }
        }
    }
    
    /// Renders the thumbnails needed to display a favorite item in the Favorites Display Widget.
    ///
    /// - Parameter favorite: The `Media` item to render thumbnails for.
    /// - Returns: The primary thumbnail for the `Media` item used in contexts outside of the
    ///   Favorites Display Widget.
    static func renderThumbnailsForFavorite(_ favorite: Media) async {
        for index in 0..<3 {
            let scaleOffset: Float = 0.04 * pow(0.5, Float(index))
            let rotationY: Float = (index == 0 ? 0 : (-0.4 - (0.075 * Float(index))))
            
            switch favorite.type {
            case .vinylRecord:
                let scale: Float = 0.11 + scaleOffset
                
                let _ = await PhysicalMedia.vinylRecordThumbnailImage(
                    favorite.albumArtworkURL,
                    favorite.mediaColor,
                    coverColor: favorite.coverColor,
                    scale: scale,
                    rotationXY: (0, rotationY),
                )
            case .compactDisc:
                let scale: Float = 0.155 + scaleOffset
                let rotationYOffset: Float = (index == 0 ? 0.18 : 0)
                
                let _ = await PhysicalMedia.compactDiscThumbnailImage(
                    favorite.albumArtworkURL,
                    coverColor: favorite.coverColor,
                    scale: scale,
                    rotationXY: (0, (rotationY + rotationYOffset)),
                )
            case .compactCassette:
                let scale: Float = 0.31 + scaleOffset
                
                let _ = await PhysicalMedia.compactCassetteThumbnailImage(
                    favorite.albumArtworkURL,
                    favorite.mediaColor,
                    coverColor: favorite.coverColor,
                    scale: scale,
                    rotationXY: (0, rotationY),
                )
            }
        }
    }
}
