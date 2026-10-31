//
//  WidgetRenderer.swift
//  Physical
//
//  Created by Spencer Hartland on 10/29/26.
//

import Foundation
import PhysicalMediaKit

actor WidgetRenderer {
    static func renderThumbnailsForFavorites(_ favorites: [Media]) async {
        for favorite in favorites { await renderThumbnailsForFavorite(favorite) }
    }
    
    static func renderThumbnailsForFavorite(_ favorite: Media) async {
        for index in 0..<3 {
            let scaleOffset: Float = 0.04 * pow(0.5, Float(index))
            let rotationY: Float = (index == 0 ? 0 : (-0.4 - (0.075 * Float(index))))
            
            switch favorite.type {
            case .vinylRecord:
                let scale: Float = 0.11 + scaleOffset
                
                let _ = await PhysicalMedia.vinylRecordThumbnailImage(
                    favorite.albumArtworkURL,
                    favorite.color,
                    scale: scale,
                    rotationXY: (0, rotationY),
                )
            case .compactDisc:
                let scale: Float = 0.155 + scaleOffset
                let rotationYOffset: Float = (index == 0 ? 0.18 : 0)
                
                let _ = await PhysicalMedia.compactDiscThumbnailImage(
                    favorite.albumArtworkURL,
                    scale: scale,
                    rotationXY: (0, (rotationY + rotationYOffset)),
                )
            case .compactCassette:
                let scale: Float = 0.31 + scaleOffset
                
                let _ = await PhysicalMedia.compactCassetteThumbnailImage(
                    favorite.albumArtworkURL,
                    favorite.color,
                    scale: scale,
                    rotationXY: (0, rotationY),
                )
            }
        }
    }
}
