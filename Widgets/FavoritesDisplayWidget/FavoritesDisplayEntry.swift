//
//  FavoritesDisplayEntry.swift
//  Physical
//
//  Created by Spencer Hartland on 5/18/26.
//

import Foundation
import WidgetKit
import SwiftUI
import PhysicalMediaKit

struct FavoritesDisplayEntry: TimelineEntry {
    let date: Date
    let favorites: [MediaEntity]
    let thumbnailKeys: [String]
    
    init() {
        self.date = Date()
        self.favorites = []
        self.thumbnailKeys = []
    }
    
    init(date: Date, favorites: [MediaEntity], thumbnailKeys: [String]) {
        self.date = date
        self.favorites = favorites
        self.thumbnailKeys = thumbnailKeys
    }
}
