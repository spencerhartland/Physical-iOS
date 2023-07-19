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
    private var rawType: String
    private var rawCondition: String
    
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
    var releaseDate: Date
    var title: String
    var artist: String
    var tracks: [String]
    var images: [String]
    
    init() {
        self.rawType = MediaType.vinylRecord.rawValue
        self.rawCondition = MediaCondition.nearMint.rawValue
        self.releaseDate = .now
        self.title = ""
        self.artist = ""
        self.tracks = []
        self.images = []
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
