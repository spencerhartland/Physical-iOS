//
//  Media.swift
//  Vinyls
//
//  Created by Spencer Hartland on 7/8/23.
//

import Foundation
import SwiftData

@Model
final class Media {
    var rawType: String
    var rawCondition: String
    
    var type: MediaType {
        get {
            return MediaType(rawValue: self.rawType)!
        }
        set {
            self.rawType = newValue.rawValue
        }
    }
    var condition: MediaCondition {
        get {
            return MediaCondition(rawValue: self.rawCondition)!
        }
        set {
            self.rawCondition = newValue.rawValue
        }
    }
    let dateAdded: Date
    var releaseDate: Date
    var title: String
    var artist: String
    var tracks: [String]
    var displaysOfficialArtwork: Bool
    /// The URL string for the official album artwork provided by Apple Music.
    var albumArtworkURL: String
    /// A collection of keys associated with user-generated images.
    var imageKeys: [String]
    var notes: String
    var genre: String
    var isFavorite: Bool
    var isOwned: Bool
    
    init() {
        self.rawType = MediaType.vinylRecord.rawValue
        self.rawCondition = MediaCondition.nearMint.rawValue
        self.dateAdded = .now
        self.releaseDate = .now
        self.title = ""
        self.artist = ""
        self.tracks = []
        self.displaysOfficialArtwork = true
        self.albumArtworkURL = ""
        self.imageKeys = []
        self.notes = ""
        self.genre = ""
        self.isFavorite = false
        self.isOwned = true
    }
    
    enum MediaType: String, Codable, CaseIterable, Identifiable, Equatable {
        var id: Self {
            return self
        }
        case vinylRecord = "Vinyl Record"
        case compactDisc = "Compact Disc"
        case compactCassette = "Compact Cassette"
    }
    
    enum MediaCondition: String, Codable, CaseIterable, Identifiable, Equatable {
        var id: Self {
            return self
        }
        case mint = "Mint"
        case nearMint = "Near Mint"
        case excellent = "Excellent"
        case veryGood = "Very Good"
        case good = "Good"
        case fair = "Fair"
        case poor = "Poor"
    }
}
