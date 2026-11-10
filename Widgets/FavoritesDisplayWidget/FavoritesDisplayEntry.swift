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
    let thumbnails: [UIImage]
    
    init() {
        self.date = Date()
        self.favorites = []
        self.thumbnails = []
    }
    
    init(date: Date, favorites: [MediaEntity], thumbnails: [UIImage]) {
        self.date = date
        self.favorites = favorites
        self.thumbnails = thumbnails
    }
}
