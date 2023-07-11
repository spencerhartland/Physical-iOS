//
//  SampleCollection.swift
//  Vinyls
//
//  Created by Spencer Hartland on 7/8/23.
//
import Foundation

struct SampleCollection {
    static var contents: [Media] = [
        Media(type: .vinylRecord, condition: .mint, releaseDate: Date(timeIntervalSince1970: 1582329600), title: "Miss Anthropocene (Deluxe Edition)", artist: "Grimes", tracks: [
            "So Heavy I Fell Through the Earth (Art Mix)",
            "Darkseid (ft. 潘PAN)",
            "Delete Forever",
            "Violence (ft. i_o)",
            "4 Æm",
            "New Gods",
            "My Name is Dark (Art Mix)",
            "You'll miss me when I'm not around",
            "Before the Fever",
            "Idoru",
            "We Appreciate Power (ft. HANA)",
            "So Heavy I Fell Through the Earth (Algorithm Mix)",
            "Violence (Club Mix) (ft. i_o)",
            "My Name is Dark (Algorithm Mix)",
            "IDORU (Algorithm Mix)"
        ])
    ]
}
