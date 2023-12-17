//
//  SocialProfileCollectionView.swift
//  Physical
//
//  Created by Spencer Hartland on 8/24/23.
//

import SwiftUI
import SwiftData

struct SocialProfileCollectionView: View {
    @Query(
        filter: Section.favorites.predicate,
        sort: \.title
    )
    private var favoriteMedia: [Media]
    
    @Query(
        filter: Section.vinylRecords.predicate,
        sort: \.title
    )
    private var vinylRecords: [Media]
    
    @Query(
        filter: Section.compactDiscs.predicate,
        sort: \.title
    )
    private var compactDiscs: [Media]
    
    @Query(
        filter: Section.compactCassettes.predicate,
        sort: \.title
    )
    private var compactCassettes: [Media]
    
    @Environment(\.screenSize) private var screenSize: CGSize
    
    var body: some View {
        // Favorites section
        CollectionSection(
            Section.favorites.rawValue,
            content: favoriteMedia,
            thumbnailWidth: screenSize.width - 24,
            steppedScrolling: true
        )
        
        // Vinyl records
        CollectionSection(
            Section.vinylRecords.rawValue,
            content: vinylRecords,
            thumbnailsOrnamented: false
        )
        
        // Compact discs
        CollectionSection(
            Section.compactDiscs.rawValue,
            content: compactDiscs,
            thumbnailsOrnamented: false
        )
        
        // Compact cassettes
        CollectionSection(
            Section.compactCassettes.rawValue,
            content: compactCassettes,
            thumbnailsOrnamented: false
        )
    }
    
    private enum Section: String {
        case favorites = "Favorites"
        case vinylRecords = "Vinyl Records"
        case compactDiscs = "Compact Discs"
        case compactCassettes = "Compact Cassettes"
        
        var predicate: Predicate<Media> {
            let vinylRecord = Media.MediaType.vinylRecord.rawValue
            let compactDisc = Media.MediaType.compactDisc.rawValue
            let compactCassette = Media.MediaType.compactCassette.rawValue
            
            switch self {
            case .favorites:
                return #Predicate { $0.isFavorite }
            case .vinylRecords:
                return #Predicate { $0.rawType == vinylRecord }
            case .compactDiscs:
                return #Predicate { $0.rawType == compactDisc }
            case .compactCassettes:
                return #Predicate { $0.rawType == compactCassette }
            }
        }
    }
}

#Preview {
    @State var screenSize: CGSize = {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        return window.screen.bounds.size
    }()
    
    return ScrollView {
        SocialProfileCollectionView()
    }
    .environment(\.screenSize, screenSize)
    .modelContainer(previewContainer)
}
