//
//  MediaDraft.swift
//  Physical
//
//  Created by Spencer Hartland on 1/29/26.
//

import Foundation
import UIKit
import MusicKit

@Observable
final class MediaDraft {
    var rawType: String
    var rawCondition: String
    
    var type: Media.MediaType {
        get {
            return Media.MediaType(rawValue: self.rawType)!
        }
        set {
            self.rawType = newValue.rawValue
        }
    }
    var condition: Media.MediaCondition {
        get {
            return Media.MediaCondition(rawValue: self.rawCondition)!
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
    var color: UIColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1.0)
    var notes: String
    var genre: String
    var isFavorite: Bool
    var isOwned: Bool
    
    init() {
        self.rawType = Media.MediaType.vinylRecord.rawValue
        self.rawCondition = Media.MediaCondition.nearMint.rawValue
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
    
    init(from media: Media) {
        self.rawType = media.rawType
        self.rawCondition = media.rawCondition
        self.dateAdded = media.dateAdded
        self.releaseDate = media.releaseDate
        self.title = media.title
        self.artist = media.artist
        self.tracks = media.tracks
        self.displaysOfficialArtwork = media.displaysOfficialArtwork
        self.albumArtworkURL = media.albumArtworkURL
        self.color = media.color
        self.imageKeys = media.imageKeys
        self.notes = media.notes
        self.genre = media.genre
        self.isFavorite = media.isFavorite
        self.isOwned = media.isOwned
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
        self.albumArtworkURL = getArtworkURL(from: album.artwork)
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
    
    private func getArtworkURL(from artwork: Artwork?) -> URL? {
        guard let artwork = artwork,
              let url = artwork.url(width: 1080, height: 1080) else {
            return nil
        }
        return url
    }
}
