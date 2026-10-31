//
//  CollectionFilter.swift
//  Physical
//
//  Created by Spencer Hartland on 1/9/26.
//

import Foundation
import PhysicalMediaKit

enum CollectionFilter: String, Identifiable, CaseIterable {
    case allMedia = "All Media"
    case favoritesOnly = "Favorites"
    case vinylRecordsOnly = "Vinyl Records"
    case cdsOnly = "Compact Discs"
    case cassettesOnly = "Compact Cassettes"
    case ownedOnly = "Owned"
    case wantedOnly = "Wanted"
    
    var id: Self {
        return self
    }
    
    var predicate: Predicate<Media> {
        let vinylRecord = MediaType.vinylRecord.rawValue
        let compactDisc = MediaType.compactDisc.rawValue
        let compactCassette = MediaType.compactCassette.rawValue
        
        switch self {
        case .allMedia:
            return #Predicate { _ in return true }
        case .favoritesOnly:
            return #Predicate { $0.isFavorite }
        case .vinylRecordsOnly:
            return #Predicate { $0.rawType == vinylRecord }
        case .cdsOnly:
            return #Predicate { $0.rawType == compactDisc }
        case .cassettesOnly:
            return #Predicate { $0.rawType == compactCassette }
        case .ownedOnly:
            return #Predicate { $0.isOwned == true }
        case .wantedOnly:
            return #Predicate { $0.isOwned == false }
        }
    }
}
