//
//  SampleCollection.swift
//  Physical
//
//  Created by Spencer Hartland on 8/16/23.
//

import Foundation

struct SampleCollection {
    static var contents: [Media] = [
        Media(
            artworkURLString: "https://m.media-amazon.com/images/I/51clQVJViDL._UXNaN_FMjpg_QL85_.jpg",
            title: "Miss Anthropocene (Deluxe Edition)",
            artist: "Grimes",
            type: .vinylRecord,
            tracks: [
                "So Heavy I Fell Through The Earth (Art Mix)",
                "Darkseid",
                "Delete Forever"
            ],
            genre: "Electronic",
            releaseDate: .now,
            isFavorite: true,
            isOwned: true
        ),
        Media(
            artworkURLString: "https://upload.wikimedia.org/wikipedia/en/d/d9/Grimes_-_Art_Angels.png",
            title: "Art Angels",
            artist: "Grimes",
            type: .vinylRecord,
            tracks: [
                "Laughing and not being normal",
                "Scream",
                "California"
            ],
            genre: "Electronic",
            releaseDate: .now,
            isFavorite: true,
            isOwned: true
        ),
        Media(
            artworkURLString: "https://upload.wikimedia.org/wikipedia/en/thumb/f/fb/Grimes_-_Halfaxa_cover.png/220px-Grimes_-_Halfaxa_cover.png",
            title: "Halfaxa",
            artist: "Grimes",
            type: .vinylRecord,
            tracks: [
                "Outer",
                "Intro / Flowers",
                "Weregild"
            ],
            genre: "Electronic",
            releaseDate: .now,
            isFavorite: true,
            isOwned: true
        ),
        Media(
            artworkURLString: "https://upload.wikimedia.org/wikipedia/en/c/cc/Grimes_-_Geidi_Primes_album_cover.png",
            title: "Geidi Primes",
            artist: "Grimes",
            type: .vinylRecord,
            tracks: [
                "Caladan",
                "Sardaukar Levenbrech",
                "Zoal, Face Dancer"
            ],
            genre: "Electronic",
            releaseDate: .now,
            isFavorite: false,
            isOwned: true
        ),
        Media(
            artworkURLString: "https://upload.wikimedia.org/wikipedia/en/2/2c/Björk_-_Utopia_album_cover.png",
            title: "Utopia",
            artist: "Bjork",
            type: .compactCassette,
            tracks: [
                "Arisen My Senses",
                "Blissing Me",
                "The Gate"
            ],
            genre: "Electronic",
            releaseDate: .now,
            isFavorite: true,
            isOwned: true
        )
        ,
        Media(
            artworkURLString: "https://upload.wikimedia.org/wikipedia/en/f/f8/Taylor_Swift_-_Folklore.png",
            title: "Folklore",
            artist: "Taylor Swift",
            type: .compactDisc,
            tracks: [
                "The 1",
                "Cardigan",
                "The Last Great American Dynasty"
            ],
            genre: "Alternative",
            releaseDate: .now,
            isFavorite: false,
            isOwned: true
        )
    ]
}
