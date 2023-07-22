//
//  MediaGrid.swift
//  Physical
//
//  Created by Spencer Hartland on 7/18/23.
//

import SwiftUI
import SwiftData

enum MediaFilter: String, Identifiable, CaseIterable {
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

enum MediaSorting: String, Identifiable, CaseIterable {
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

struct MediaGrid: View {
    private var collection: [Media]
    private var sorting: MediaSorting
    
    @State private var sections: [String:[Media]] = [:]
    
    init(_ collection: [Media], sorting: MediaSorting, filter: MediaFilter) {
        do {
            self.sorting = sorting
            self.collection = try collection.filter(filter.predicate).sorted(using: sorting.sortDescriptor)
        } catch {
            print("Error filtering and sorting collection: \(error.localizedDescription)")
            self.collection = collection
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 128))], alignment: .leading, spacing: 16) {
                if !sections.isEmpty {
                    ForEach(Array(sections.keys), id: \.self) { key in
                        if let section = sections[key] {
                            Section {
                                ForEach(section) { media in
                                    NavigationLink {
                                        MediaDetailView(media: media)
                                    } label: {
                                        MediaThumbnail(for: media, ornamented: (sorting == .byMediaType) ? false : true)
                                    }
                                }
                            } header: {
                                Text(key)
                                    .font(.title2.weight(.semibold))
                            }
                        }
                    }
                } else {
                    // All media
                    Section {
                        ForEach(collection) { media in
                            NavigationLink {
                                MediaDetailView(media: media)
                            } label: {
                                MediaThumbnail(for: media)
                            }
                        }
                    } header: {
                        Text(sorting.rawValue)
                            .font(.title2.weight(.semibold))
                    }
                }
            }
            .padding()
        }
        .onAppear {
            sortIntoSections(sortValue: sorting)
        }
        .onChange(of: sorting) { _, newValue in
            sortIntoSections(sortValue: newValue)
        }
        .onChange(of: collection) { _, _ in
            sortIntoSections(sortValue: sorting)
        }
    }
    
    @MainActor
    private func sortIntoSections(sortValue: MediaSorting) {
        do {
            sections = [:]
            switch sortValue {
            case .byMediaType:
                var type = ""
                for item in collection {
                    if item.type.rawValue != type {
                        type = item.type.rawValue
                        sections[type] = try collection.filter(#Predicate {$0.rawType.contains(type) })
                    }
                }
            case .byMediaCondition:
                var condition = ""
                for item in collection {
                    if item.condition.rawValue != condition {
                        condition = item.condition.rawValue
                        sections[condition] = try collection.filter(#Predicate{ $0.rawCondition.contains(condition) })
                    }
                }
            case .byArtist:
                var artist = ""
                for item in collection {
                    if item.artist != artist {
                        artist = item.artist
                        sections[artist] = try collection.filter(#Predicate{ $0.artist.contains(artist) })
                    }
                }
            default:
                return
            }
        } catch {
            print("Failed to sort collection: \(error.localizedDescription)")
        }
    }
}
