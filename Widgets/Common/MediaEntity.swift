//
//  MediaEntity.swift
//  Physical
//
//  Created by Spencer Hartland on 5/11/26.
//

import Foundation
import AppIntents
import UIKit
import SwiftData
import SwiftUI
import PhysicalMediaKit

struct MediaEntity: AppEntity, Identifiable {
    var id: UUID
    var title: String
    var artist: String
    var albumArtworkURL: URL?
    var dominantColor: Color?
    var mediaColor: UIColor
    var coverColor: UIColor?
    var rawType: String
    var type: MediaType {
        get {
            return MediaType(rawValue: self.rawType)!
        }
        set {
            self.rawType = newValue.rawValue
        }
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Media"
    static var defaultQuery = MediaQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
    
    init(from media: Media) {
        self.init(
            id: media.id,
            type: media.type,
            title: media.title,
            artist: media.artist,
            albumArtworkURL: media.albumArtworkURL,
            dominantColor: media.dominantColor,
            mediaColor: media.mediaColor,
            coverColor: media.coverColor
        )
    }
    
    private init(
        id: UUID,
        type: MediaType,
        title: String,
        artist: String,
        albumArtworkURL: URL?,
        dominantColor: Color?,
        mediaColor: UIColor,
        coverColor: UIColor?,
    ) {
        self.id = id
        self.rawType = type.rawValue
        self.title = title
        self.artist = artist
        self.albumArtworkURL = albumArtworkURL
        self.dominantColor = dominantColor
        self.mediaColor = mediaColor
        self.coverColor = coverColor
    }
}
