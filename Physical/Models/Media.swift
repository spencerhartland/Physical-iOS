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
    var dateAdded: Date
    var releaseDate: Date
    var title: String
    var artist: String
    var tracks: [String]
    var displaysOfficialArtwork: Bool
    /// The URL string for the official album artwork provided by Apple Music.
    var albumArtworkURL: String
    /// A collection of keys associated with user-generated images.
    var imageKeys: [String]
    @Attribute(.transformable(by: UIColorValueTransformer.self)) var color: UIColor = UIColor.black
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
    
    init(
        artworkURLString: String,
        color: UIColor = .black,
        title: String,
        artist: String,
        type: Media.MediaType,
        tracks: [String],
        genre: String,
        releaseDate: Date,
        isFavorite: Bool,
        isOwned: Bool
    ) {
        self.rawType = type.rawValue
        self.rawCondition = MediaCondition.nearMint.rawValue
        self.dateAdded = .now
        self.displaysOfficialArtwork = true
        self.imageKeys = []
        self.notes = ""
        
        self.albumArtworkURL = artworkURLString
        self.color = color
        self.title = title
        self.artist = artist
        self.tracks = tracks
        self.genre = genre
        self.releaseDate = releaseDate
        self.isFavorite = isFavorite
        self.isOwned = isOwned
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
    
    @MainActor
    public func resetInfo() {
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
    
    @MainActor
    public func updateWithInfo(from album: Album) {
        Task {
            let albumRelatedData = await fetchRelatedData(from: album)
            if let data = albumRelatedData {
                self.updateWithDetailedInfo(genre: data.0, tracks: data.1)
            }
        }
        self.title = album.title
        self.artist = album.artistName
        self.releaseDate = album.releaseDate ?? .now
        if let url = getArtworkURLString(from: album.artwork) {
            self.albumArtworkURL = url
        }
    }
    
    @MainActor
    private func updateWithDetailedInfo(genre: String, tracks: [String]) {
        self.genre = genre
        self.tracks = tracks
    }
    
    private func fetchRelatedData(from album: Album) async -> (String, [String])? {
        do {
            let detailedAlbum = try await album.with([.tracks, .genres])
            guard let tracks = detailedAlbum.tracks,
                  let genres = detailedAlbum.genres,
                  let primaryGenre = genres.first else {
                print("Error fetching detailed album.")
                return nil
            }
            var tracksArray = [String]()
            for track in tracks {
                tracksArray.append(track.title)
            }
            return (primaryGenre.name, tracksArray)
        } catch {
            print("Error fetching detailed album: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func getArtworkURLString(from artwork: Artwork?) -> String? {
        guard let artwork = artwork,
              let url = artwork.url(width: 1080, height: 1080) else {
            return nil
        }
        return url.absoluteString
    }
}
