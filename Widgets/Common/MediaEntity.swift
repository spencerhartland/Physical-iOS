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
    var color: UIColor
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
        self.id = media.id
        self.rawType = media.type.rawValue
        self.title = media.title
        self.artist = media.artist
        self.albumArtworkURL = media.albumArtworkURL
        self.dominantColor = media.dominantColor
        self.color = media.mediaColor
    }
    
    init(
        id: UUID,
        type: MediaType,
        title: String,
        artist: String,
        albumArtworkURL: URL?,
        dominantColor: Color?,
        color: UIColor,
    ) {
        self.id = id
        self.rawType = type.rawValue
        self.title = title
        self.artist = artist
        self.albumArtworkURL = albumArtworkURL
        self.dominantColor = dominantColor
        self.color = color
    }
}
