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

actor WidgetHelper {
    static func prepareFavoritesForWidget(_ favorites: [Media]) async {
        for favorite in favorites {
            let primaryThumbnail = await renderThumbnailsForFavorite(favorite)
            favorite.dominantColors = await calculateDominantColorsInThumbnail(primaryThumbnail)
        }
    }
    
    static func calculateDominantColorsInThumbnail(
        _ thumbnail: UIImage?
    ) async -> [DominantColor] {
        guard let cgImage = thumbnail?.cgImage else { return [] }
        return await DominantColorsCalculator.dominantColors(in: cgImage)
    }
    
    /// Renders the thumbnails needed to display a favorite item in the Favorites Display Widget.
    ///
    /// - Parameter favorite: The `Media` item to render thumbnails for.
    /// - Returns: The primary thumbnail for the `Media` item used in contexts outside of the
    ///   Favorites Display Widget.
    static func renderThumbnailsForFavorite(_ favorite: Media) async -> UIImage? {
        var primaryThumbnail: UIImage?
        
        for index in 0..<3 {
            let scaleOffset: Float = 0.04 * pow(0.5, Float(index))
            let rotationY: Float = (index == 0 ? 0 : (-0.4 - (0.075 * Float(index))))
            
            var thumbnail: UIImage?
            
            switch favorite.type {
            case .vinylRecord:
                let scale: Float = 0.11 + scaleOffset
                
                thumbnail = await PhysicalMedia.vinylRecordThumbnailImage(
                    favorite.albumArtworkURL,
                    favorite.mediaColor,
                    scale: scale,
                    rotationXY: (0, rotationY),
                )
            case .compactDisc:
                let scale: Float = 0.155 + scaleOffset
                let rotationYOffset: Float = (index == 0 ? 0.18 : 0)
                
                thumbnail = await PhysicalMedia.compactDiscThumbnailImage(
                    favorite.albumArtworkURL,
                    scale: scale,
                    rotationXY: (0, (rotationY + rotationYOffset)),
                )
            case .compactCassette:
                let scale: Float = 0.31 + scaleOffset
                
                thumbnail = await PhysicalMedia.compactCassetteThumbnailImage(
                    favorite.albumArtworkURL,
                    favorite.mediaColor,
                    scale: scale,
                    rotationXY: (0, rotationY),
                )
            }
            
            if index == 0 { primaryThumbnail = thumbnail }
        }
        
        return primaryThumbnail
    }
}
