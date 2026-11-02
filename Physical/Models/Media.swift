//
//  Media.swift
//  Vinyls
//
//  Created by Spencer Hartland on 7/8/23.
//

import Foundation
import SwiftData
import MusicKit
import UIKit
import WidgetKit
import PhysicalMediaKit

typealias Media = MediaSchemaV1.Media

// TODO: Add dominant colors
enum MediaSchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)
    static let models: [any PersistentModel.Type] = [Media.self]
    
    @Model
    final class Media {
        enum Condition: String, Codable, CaseIterable, Identifiable, Equatable {
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
        
        var rawType: String
        var rawCondition: String
        
        var id: UUID = UUID()
        var type: MediaType {
            get {
                return MediaType(rawValue: self.rawType)!
            }
            set {
                self.rawType = newValue.rawValue
            }
        }
        var condition: Condition {
            get {
                return Condition(rawValue: self.rawCondition)!
            }
            set {
                self.rawCondition = newValue.rawValue
            }
        }
        var dateAdded: Date
        var releaseDate: Date
        var title: String
        var artist: String
        var tracks: [String]
        var displaysOfficialArtwork: Bool
        /// The URL for the official album artwork provided by Apple Music.
        var albumArtworkURL: URL?
        /// A collection of keys associated with user-generated images.
        var imageKeys: [String]
        @Attribute(.transformable(by: UIColorValueTransformer.self))
        var color: UIColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1.0)
        var notes: String
        var genre: String
        var isFavorite: Bool
        var isOwned: Bool
        
        init() {
            self.rawType = MediaType.vinylRecord.rawValue
            self.rawCondition = Condition.nearMint.rawValue
            self.dateAdded = .now
            self.releaseDate = .now
            self.title = ""
            self.artist = ""
            self.tracks = []
            self.displaysOfficialArtwork = true
            self.albumArtworkURL = nil
            self.imageKeys = []
            self.notes = ""
            self.genre = ""
            self.isFavorite = false
            self.isOwned = true
        }
        
        init(
            artworkURL: URL? = nil,
            color: UIColor = .black,
            title: String,
            artist: String,
            type: MediaType,
            tracks: [String],
            genre: String,
            releaseDate: Date,
            isFavorite: Bool,
            isOwned: Bool
        ) {
            self.rawType = type.rawValue
            self.rawCondition = Condition.nearMint.rawValue
            self.dateAdded = .now
            self.displaysOfficialArtwork = true
            self.imageKeys = []
            self.notes = ""
            
            self.albumArtworkURL = artworkURL
            self.color = color
            self.title = title
            self.artist = artist
            self.tracks = tracks
            self.genre = genre
            self.releaseDate = releaseDate
            self.isFavorite = isFavorite
            self.isOwned = isOwned
        }
        
        init(from draft: MediaDraft) {
            self.rawType = draft.rawType
            self.rawCondition = draft.rawCondition
            self.dateAdded = draft.dateAdded
            self.releaseDate = draft.releaseDate
            self.title = draft.title
            self.artist = draft.artist
            self.tracks = draft.tracks
            self.displaysOfficialArtwork = draft.displaysOfficialArtwork
            self.albumArtworkURL = draft.albumArtworkURL
            self.imageKeys = draft.imageKeys
            self.color = draft.color
            self.notes = draft.notes
            self.genre = draft.genre
            self.isFavorite = draft.isFavorite
            self.isOwned = draft.isOwned
        }
        
        func applyChanges(from draft: MediaDraft) {
            self.rawType = draft.rawType
            self.rawCondition = draft.rawCondition
            self.dateAdded = draft.dateAdded
            self.releaseDate = draft.releaseDate
            self.title = draft.title
            self.artist = draft.artist
            self.tracks = draft.tracks
            self.displaysOfficialArtwork = draft.displaysOfficialArtwork
            self.albumArtworkURL = draft.albumArtworkURL
            self.imageKeys = draft.imageKeys
            self.color = draft.color
            self.notes = draft.notes
            self.genre = draft.genre
            self.isFavorite = draft.isFavorite
            self.isOwned = draft.isOwned
        }
    }
}

enum MediaSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static let models: [any PersistentModel.Type] = [Media.self]
    
    @Model
    final class Media {
        enum Condition: String, Codable, CaseIterable, Identifiable, Equatable {
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
        
        var rawType: String
        var rawCondition: String
        
        var id: UUID = UUID()
        var type: MediaType {
            get {
                return MediaType(rawValue: self.rawType)!
            }
            set {
                self.rawType = newValue.rawValue
            }
        }
        var condition: Condition {
            get {
                return Condition(rawValue: self.rawCondition)!
            }
            set {
                self.rawCondition = newValue.rawValue
            }
        }
        var dateAdded: Date
        var releaseDate: Date
        var title: String
        var artist: String
        var tracks: [String]
        var displaysOfficialArtwork: Bool
        /// The URL for the official album artwork provided by Apple Music.
        var albumArtworkURL: URL?
        /// A collection of keys associated with user-generated images.
        var imageKeys: [String]
        @Attribute(.transformable(by: UIColorValueTransformer.self))
        var color: UIColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1.0)
        var notes: String
        var genre: String
        var isFavorite: Bool
        var isOwned: Bool
        
        init() {
            self.rawType = MediaType.vinylRecord.rawValue
            self.rawCondition = Condition.nearMint.rawValue
            self.dateAdded = .now
            self.releaseDate = .now
            self.title = ""
            self.artist = ""
            self.tracks = []
            self.displaysOfficialArtwork = true
            self.albumArtworkURL = nil
            self.imageKeys = []
            self.notes = ""
            self.genre = ""
            self.isFavorite = false
            self.isOwned = true
        }
        
        init(
            artworkURL: URL? = nil,
            color: UIColor = .black,
            title: String,
            artist: String,
            type: MediaType,
            tracks: [String],
            genre: String,
            releaseDate: Date,
            isFavorite: Bool,
            isOwned: Bool
        ) {
            self.rawType = type.rawValue
            self.rawCondition = Condition.nearMint.rawValue
            self.dateAdded = .now
            self.displaysOfficialArtwork = true
            self.imageKeys = []
            self.notes = ""
            
            self.albumArtworkURL = artworkURL
            self.color = color
            self.title = title
            self.artist = artist
            self.tracks = tracks
            self.genre = genre
            self.releaseDate = releaseDate
            self.isFavorite = isFavorite
            self.isOwned = isOwned
        }
        
        init(from draft: MediaDraft) {
            self.rawType = draft.rawType
            self.rawCondition = draft.rawCondition
            self.dateAdded = draft.dateAdded
            self.releaseDate = draft.releaseDate
            self.title = draft.title
            self.artist = draft.artist
            self.tracks = draft.tracks
            self.displaysOfficialArtwork = draft.displaysOfficialArtwork
            self.albumArtworkURL = draft.albumArtworkURL
            self.imageKeys = draft.imageKeys
            self.color = draft.color
            self.notes = draft.notes
            self.genre = draft.genre
            self.isFavorite = draft.isFavorite
            self.isOwned = draft.isOwned
        }
        
        func applyChanges(from draft: MediaDraft) {
            self.rawType = draft.rawType
            self.rawCondition = draft.rawCondition
            self.dateAdded = draft.dateAdded
            self.releaseDate = draft.releaseDate
            self.title = draft.title
            self.artist = draft.artist
            self.tracks = draft.tracks
            self.displaysOfficialArtwork = draft.displaysOfficialArtwork
            self.albumArtworkURL = draft.albumArtworkURL
            self.imageKeys = draft.imageKeys
            self.color = draft.color
            self.notes = draft.notes
            self.genre = draft.genre
            self.isFavorite = draft.isFavorite
            self.isOwned = draft.isOwned
        }
    }
}
