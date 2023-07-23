//
//  CollectionOrganizer.swift
//  Physical
//
//  Created by Spencer Hartland on 7/22/23.
//

import Foundation
import SwiftData

enum CollectionFilter: String, Identifiable, CaseIterable {
    case allMedia = "All Media"
    case favoritesOnly = "Favorites"
    case vinylRecordsOnly = "Vinyl Record"
    case cdsOnly = "Compact Disc"
    case cassettesOnly = "Compact Cassette"
    
    var id: Self {
        return self
    }
    
    var predicate: Predicate<Media> {
        let vinylRecord = Media.MediaType.vinylRecord.rawValue
        let compactDisc = Media.MediaType.compactDisc.rawValue
        let compactCassette = Media.MediaType.compactCassette.rawValue
        
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
        }
    }
}

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

struct OrganizerSection: Identifiable {
    var id = UUID()
    var title: String
    var content: [Media]
}

@Observable
final class CollectionOrganizer {
    var sorting: CollectionSorting = .recentlyAdded
    var filter: CollectionFilter = .allMedia
    var sections: [OrganizerSection] = []
    
    func makeSections(from collection: [Media]) {
        let sortedCollection = filterAndSort(collection)
        sections = []
        do {
            switch sorting {
            case .byMediaType:
                for type in Media.MediaType.allCases {
                    let media = try sortedCollection.filter(#Predicate {$0.rawType == type.rawValue })
                    sections.append(OrganizerSection(title: type.rawValue, content: media))
                }
            case .byMediaCondition:
                for condition in Media.MediaCondition.allCases {
                    let media = try sortedCollection.filter(#Predicate{ $0.rawCondition == condition.rawValue })
                    sections.append(OrganizerSection(title: condition.rawValue, content: media))
                }
            case .byArtist:
                var artist = ""
                for item in sortedCollection {
                    if item.artist != artist {
                        artist = item.artist
                        let media = try sortedCollection.filter(#Predicate{ $0.artist.contains(artist) })
                        sections.append(OrganizerSection(title: artist, content: media))
                    }
                }
            default:
                sections.append(OrganizerSection(title: sorting.rawValue, content: sortedCollection))
            }
        } catch {
            print("Failed to sort collection: \(error.localizedDescription)")
        }
    }
    
    private func filterAndSort(_ collection: [Media]) -> [Media] {
        var result: [Media] = []
        do {
            result = try collection.filter(filter.predicate).sorted(using: sorting.sortDescriptor)
        } catch {
            print("Error organizing collection  with provided predicate and sort descriptor: \(error.localizedDescription)")
        }
        return result
    }
}
