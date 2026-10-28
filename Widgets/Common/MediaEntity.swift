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
import PhysicalMediaKit

struct MediaEntity: AppEntity, Identifiable {
    var id: UUID
    var title: String
    var artist: String
    var albumArtworkURL: URL?
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
        self.color = media.color
    }
    
    init(
        id: UUID,
        type: MediaType,
        title: String,
        artist: String,
        albumArtworkURL: URL?,
        color: UIColor,
    ) {
        self.id = id
        self.rawType = type.rawValue
        self.title = title
        self.artist = artist
        self.albumArtworkURL = albumArtworkURL
        self.color = color
    }
}
