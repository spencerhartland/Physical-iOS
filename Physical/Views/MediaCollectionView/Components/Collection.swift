//
//  CollectionOrganizer.swift
//  Physical
//
//  Created by Spencer Hartland on 7/22/23.
//

import Foundation
import SwiftData
import SwiftUI

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

struct Category: Identifiable {
    var id = UUID()
    var title: String
    var content: [Media]
}

struct Collection: View {
    var collection: [Category]
    var sort: CollectionSorting
    var filter: CollectionFilter
    
    init(
        _ collection: [Media],
        sort: CollectionSorting,
        filter: CollectionFilter
    ) {
        self.sort = sort
        self.filter = filter
        // First, organize and sort the collection according to the selected options
        let sorted = Collection.organize(collection, sort: sort, filter: filter)
        // Next, split the collection content up into categories if appropriate based on sort option.
        self.collection = Collection.categorize(sorted, sort: sort)
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 128))], alignment: .leading, spacing: 16) {
                ForEach(collection) { category in
                    if !category.content.isEmpty {
                        Section {
                            ForEach(category.content) { media in
                                NavigationLink {
                                    MediaDetailView(media: media)
                                } label: {
                                    MediaThumbnail(for: media, ornamented: (sort == .byMediaType) ? false : true)
                                }
                            }
                        } header: {
                            Text(category.title)
                                .font(.title2.weight(.semibold))
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // Splits the collection for sort options with discrete categories like
    // media type, media condition, or artist. Each category is given a representative
    // title and contains only the media belonging to that category.
    //
    // Sort options which are not discrete in nature, like recently added, will not be split up;
    // a single category with the title set to the sort option's raw value will be created.
    private static func categorize(_ collection: [Media], sort: CollectionSorting) -> [Category] {
        var result = [Category]()
        do {
            switch sort {
            case .byMediaType:
                for type in Media.MediaType.allCases {
                    let media = try collection.filter(#Predicate {$0.rawType == type.rawValue })
                    result.append(Category(title: type.rawValue, content: media))
                }
            case .byMediaCondition:
                for condition in Media.MediaCondition.allCases {
                    let media = try collection.filter(#Predicate{ $0.rawCondition == condition.rawValue })
                    result.append(Category(title: condition.rawValue, content: media))
                }
            case .byTitle:
                var firstLetter = ""
                for item in collection {
                    if let currentFirst = item.title.first?.lowercased(),
                       currentFirst != firstLetter {
                        firstLetter = currentFirst
                        let uppercaseCurrentFirst = currentFirst.uppercased()
                        let media = try collection.filter(#Predicate{ $0.title.starts(with: currentFirst) || $0.title.starts(with: uppercaseCurrentFirst) })
                        result.append(Category(title: String(uppercaseCurrentFirst), content: media))
                    }
                }
            case .byArtist:
                var artist = ""
                for item in collection {
                    if item.artist != artist {
                        artist = item.artist
                        let media = try collection.filter(#Predicate{ $0.artist.contains(artist) })
                        result.append(Category(title: artist, content: media))
                    }
                }
            default:
                result.append(Category(title: sort.rawValue, content: collection))
            }
        } catch {
            print("Failed to sort collection: \(error.localizedDescription)")
        }
        
        return result
    }
    
    // Organizes the entire collection by applying the selected filter and then sorting the remaining media.
    private static func organize(_ collection: [Media], sort: CollectionSorting, filter: CollectionFilter) -> [Media] {
        var result: [Media] = []
        do {
            result = try collection.filter(filter.predicate).sorted(using: sort.sortDescriptor)
        } catch {
            print("Error organizing collection  with provided predicate and sort descriptor: \(error.localizedDescription)")
        }
        return result
    }
}
