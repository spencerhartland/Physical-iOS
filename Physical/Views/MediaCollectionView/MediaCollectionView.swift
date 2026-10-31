//
//  MediaCollectionView.swift
//  Vinyls
//
//  Created by Spencer Hartland on 7/5/23.
//

import MusicKit
import PhysicalMediaKit
import SwiftData
import SwiftUI

struct MediaCollectionView: View {
    private let favoriteMenuItemText = "Favorite"
    private let favoriteMenuItemSymbol = "heart.fill"
    private let undoFavoriteMenuItemText = "Undo Favorite"
    private let undoFavoriteMenuItemSymbol = "heart.slash.fill"
    private let deleteMenuItemText = "Delete"
    private let deleteMenuItemSymbol = "trash"
    
    @AppStorage(StorageKeys.shouldAskForAppleMusicAuthorization) var shouldAskForAppleMusicAuthorization: Bool = true
    @AppStorage(StorageKeys.preferredCollectionSortOption) var preferredCollectionSortOption: String = CollectionSorting.recentlyAdded.rawValue
    
    @Environment(\.openURL) private var openURL
    @Environment(\.modelContext) private var context
    @Environment(NavigationManager.self) private var navigationManager
    
    // View State
    @State private var musicAuthorizationStatus = MusicAuthorization.currentStatus
    @State private var musicAuthorizationDenied = false
    @State private var collectionSortOption: CollectionSorting = .recentlyAdded
    @State private var collectionFilterOption: CollectionFilter = .allMedia
    @State private var currentSearch: String = ""
    
    @Query private var media: [Media]
    
    @Binding var selection: Media?
    
    let showsDetailsLink: Bool
    
    init(_ selection: Binding<Media?> = .constant(nil), showsDetailsLink: Bool = true) {
        self._selection = selection
        self.showsDetailsLink = showsDetailsLink
    }
    
    var body: some View {
        Group {
            if media.isEmpty {
                collectionIsEmptyView
            } else {
                collection
            }
        }
        .navigationTitle(collectionFilterOption == .allMedia ? "Collection" : collectionFilterOption.rawValue)
        .navigationSubtitleIfAvailable(mediaItemTotals)
        .toolbarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup {
                NavigationLink(value: MediaEntryStep.albumSearch(.manual)) {
                    Label("Add media", systemImage: "plus")
                        .labelStyle(.iconOnly)
                }
                
                NavigationLink(value: MediaEntryStep.albumSearch(.barcode)) {
                    Label("Scan barcode", systemImage: "barcode.viewfinder")
                        .labelStyle(.iconOnly)
                }
            }
            
            if #available(anyAppleOS 26.0, *) {
                ToolbarItem(placement: .bottomBar) {
                    filterAndSortMenu
                }
                ToolbarSpacer(.fixed, placement: .bottomBar)
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
            } else {
                ToolbarItem(placement: .bottomBar) {
                    filterAndSortMenu
                }
            }
        }
        .alert("Apple Music access is disabled!", isPresented: $musicAuthorizationDenied) {
            Button("Enable in Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    openURL(settingsURL)
                }
            }
            Button("Don't ask again") {
                shouldAskForAppleMusicAuthorization = false
            }
            Button("Not now", role: .cancel) {
                return
            }
        } message: {
            Text("Physical uses Apple Music to automatically populate information about new additions to your collection.")
        }
        .searchable(text: $currentSearch, prompt: "Search collection")
        .onAppear {
            rememberSortOption()
            checkForMusicAuthorization()
            selectLatestItemIfNeeded()
        }
        .onChange(of: collectionSortOption) { oldValue, newValue in
            memorizeSortOptionIfChanged(oldValue, newValue)
        }
    }
    
    private var collection: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 128))],
                alignment: .leading, spacing: 8
            ) {
                ForEach(categorizedMedia, id: \.0) { categoryTitle, categoryContents in
                    Section {
                        ForEach(categoryContents) { media in
                            if showsDetailsLink {
                                NavigationLink {
                                    MediaDetailView(for: media) {
                                        selection = nil
                                        selectLatestItemIfNeeded()
                                    }
                                    .onAppear { selection = media }
                                } label: {
                                    MediaThumbnail(for: media)
                                }
                            } else {
                                Button {
                                    selection = media
                                } label: {
                                    MediaThumbnail(for: media)
                                }
                            }
                        }
                    } header: {
                        // Do not display category title if only
                        // a single category is being displayed.
                        if categorizedMedia.count > 1 {
                            Text(categoryTitle)
                                .font(.title)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var filteredMedia: [Media] {
        var result = media

        if collectionFilterOption != .allMedia {
            result = (try? result.filter(collectionFilterOption.predicate)) ?? result
        }

        if !currentSearch.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(currentSearch) ||
                $0.artist.localizedCaseInsensitiveContains(currentSearch)
            }
        }

        result = result.sorted(using: collectionSortOption.sortDescriptor)

        return result
    }
    
    private var mediaItemTotals: Text {
        if media.isEmpty { return Text("No items") }
        
        let filteredMediaGroupedByType = Dictionary(grouping: filteredMedia, by: { $0.type })
        var vinylRecordCount = 0
        var compactDiscCount = 0
        var compactCassetteCount = 0
        
        for (type, items) in filteredMediaGroupedByType {
            switch type {
            case .vinylRecord:
                vinylRecordCount = items.count
            case .compactDisc:
                compactDiscCount = items.count
            case .compactCassette:
                compactCassetteCount = items.count
            }
        }
        
        let separator = " ・ "
        var totals = ""
        if vinylRecordCount > 0 {
            totals.append("\(vinylRecordCount) vinyl record")
            if vinylRecordCount > 1 { totals.append("s") }
        }
        if compactDiscCount > 0 {
            if !totals.isEmpty { totals.append(separator) }
            totals.append("\(compactDiscCount) CD")
            if compactDiscCount > 1 { totals.append("s") }
        }
        if compactCassetteCount > 0 {
            if !totals.isEmpty { totals.append(separator) }
            totals.append("\(compactCassetteCount) cassette")
            if compactCassetteCount > 1 { totals.append("s") }
        }
        
        return Text(totals)
    }
    
    private var categorizedMedia: [(String, [Media])] {
        switch collectionSortOption {
        case .byMediaType:
            return Dictionary(grouping: filteredMedia, by: { $0.rawType })
                .sorted { $0.key < $1.key }

        case .byMediaCondition:
            return Dictionary(grouping: filteredMedia, by: { $0.rawCondition })
                .sorted { $0.key < $1.key }

        case .byArtist:
            return Dictionary(grouping: filteredMedia, by: { $0.artist })
                .sorted { $0.key < $1.key }

        case .byTitle:
            return Dictionary(grouping: filteredMedia, by: { String($0.title.prefix(1)).uppercased() })
                .sorted { $0.key < $1.key }

        default:
            return [(collectionSortOption.rawValue, filteredMedia)]
        }
    }
    
    private var filterAndSortMenu: some View {
        Menu {
            sortMenu
            filterMenu
        } label: {
            Label("Filter and Sort", systemImage: "line.3.horizontal.decrease")
        }
    }
    
    private var filterMenu: some View {
        Menu {
            ForEach(CollectionFilter.allCases) { filter in
                if filter != .allMedia {
                    Button {
                        collectionFilterOption = (collectionFilterOption == filter) ? .allMedia : filter
                    } label: {
                        Label {
                            Text(filter.rawValue)
                        } icon: {
                            if collectionFilterOption == filter {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        } label: {
            Text("Filter")
            
            if collectionFilterOption != .allMedia {
                Text(collectionFilterOption.rawValue)
            }
        }
    }
    
    private var sortMenu: some View {
        Menu {
            ForEach(CollectionSorting.allCases) { sort in
                Button {
                    collectionSortOption = sort
                } label: {
                    Label {
                        Text(sort.rawValue)
                    } icon: {
                        if collectionSortOption == sort {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Text("Sort")
            Text(collectionSortOption.rawValue)
        }
    }
    
    private var collectionIsEmptyView: some View {
        ContentUnavailableView {
            Label("No Media", systemImage: "music.quarternote.3")
        } description: {
            Text("Add media to build your digital collection.")
        } actions: {
            NavigationLink(value: MediaEntryStep.albumSearch(.manual)) {
                Label("Add Media", systemImage: "plus")
                    .labelStyle(.titleAndIcon)
                    .padding(4)
            }
            .prominentButtonStyle()
            .buttonBorderShape(.capsule)
            .tint(.physicalGreen)
            .font(.headline)
            .fontWeight(.medium)
        }
    }
    
    private func selectLatestItemIfNeeded() {
        if let latestItem = media.last {
            guard selection == nil else { return }
            selection = latestItem
        }
    }
    
    private func rememberSortOption() {
        if let preferredSort = CollectionSorting(rawValue: preferredCollectionSortOption) {
            collectionSortOption = preferredSort
        }
    }
    
    private func memorizeSortOptionIfChanged(_ oldValue: CollectionSorting, _ newValue: CollectionSorting) {
        if newValue != oldValue {
            preferredCollectionSortOption = newValue.rawValue
        }
    }
    
    private func checkForMusicAuthorization() {
        switch MusicAuthorization.currentStatus {
        case .notDetermined:
            musicAuthorizationDenied = false
            Task.detached {
                let authorizationStatus = await MusicAuthorization.request()
                await self.update(with: authorizationStatus)
            }
        case .denied:
            musicAuthorizationDenied = true
        default:
            musicAuthorizationDenied = false
            print("Apple Music access authorized.")
        }
    }
    
    @MainActor
    private func update(with musicAuthorizationStatus: MusicAuthorization.Status) {
        self.musicAuthorizationStatus = musicAuthorizationStatus
    }
}
