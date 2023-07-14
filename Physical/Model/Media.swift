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
    var type: MediaType
    var condition: MediaCondition
    var releaseDate: Date
    var title: String
    var artist: String
    var tracks: [String]
    
    init() {
        self.type = .vinylRecord
        self.condition = .nearMint
        self.releaseDate = .now
        self.title = ""
        self.artist = ""
        self.tracks = [""]
    }
    
    init(type: MediaType, condition: MediaCondition, releaseDate: Date, title: String, artist: String, tracks: [String]) {
        self.type = type
        self.condition = condition
        self.releaseDate = releaseDate
        self.title = title
        self.artist = artist
        self.tracks = tracks
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
