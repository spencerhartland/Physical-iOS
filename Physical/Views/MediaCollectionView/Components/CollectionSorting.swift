//
//  Untitled.swift
//  Physical
//
//  Created by Spencer Hartland on 1/9/26.
//

import Foundation

enum CollectionSorting: String, Identifiable, CaseIterable {
    case recentlyAdded = "Recenty Added"
    case oldestFirst = "Oldest First"
    case byMediaType = "Media Type"
    case byMediaCondition = "Media Condition"
    case byTitle = "Title"
    case byArtist = "Artist"
    
    var id: Self {
        return self
    }
    
    var sortDescriptor: SortDescriptor<Media> {
        switch self {
        case .recentlyAdded:
            SortDescriptor(\Media.dateAdded, order: .reverse)
        case .oldestFirst:
            SortDescriptor(\Media.dateAdded, order: .forward)
        case .byMediaType:
            SortDescriptor(\Media.rawType, order: .forward)
        case .byMediaCondition:
            SortDescriptor(\Media.rawCondition, order: .forward)
        case .byTitle:
            SortDescriptor(\Media.title, order: .forward)
        case .byArtist:
            SortDescriptor(\Media.artist, order: .forward)
        }
    }
}
