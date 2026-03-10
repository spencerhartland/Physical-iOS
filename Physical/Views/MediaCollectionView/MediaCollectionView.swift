//
//  MediaCollectionView.swift
//  Vinyls
//
//  Created by Spencer Hartland on 7/5/23.
//

import SwiftUI
import SwiftData
import MusicKit

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
    @Environment(\.navigationManager) private var navigationManager
    
    // View State
    @State private var musicAuthorizationStatus = MusicAuthorization.currentStatus
    @State private var musicAuthorizationDenied = false
    @State private var collectionSortOption: CollectionSorting = .recentlyAdded
    @State private var collectionFilterOption: CollectionFilter = .allMedia
    @State private var currentSearch: String = ""
    
    @Query private var media: [Media]
    
    var body: some View {
        Group {
            if media.isEmpty {
                collectionIsEmptyView
            } else {
                collection
            }
        }
        .navigationTitle(collectionFilterOption == .allMedia ? "Collection" : collectionFilterOption.rawValue)
        .toolbarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                filterAndSortMenu
            }
            
            ToolbarItem {
                NavigationLink(value: MediaEntryStep.albumSearch(.barcode)) {
                    Label("Scan barcode", systemImage: "barcode.viewfinder")
                        .labelStyle(.iconOnly)
                }
            }
            
            if #available(iOS 26.0, *) {
                ToolbarSpacer(.fixed)
            }
            
            ToolbarItem {
                NavigationLink(value: MediaEntryStep.albumSearch(.manual)) {
                    Label("Add media", systemImage: "plus")
                        .labelStyle(.iconOnly)
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
                            NavigationLink {
                                MediaDetailView(media: media)
                            } label: {
                                MediaThumbnail(for: media)
                                    .contextMenu {
                                        Button {
                                            media.isFavorite.toggle()
                                        } label: {
                                            Label(
                                                media.isFavorite ? undoFavoriteMenuItemText : favoriteMenuItemText,
                                                systemImage: media.isFavorite ? undoFavoriteMenuItemSymbol : favoriteMenuItemSymbol)
                                        }
                                        Divider()
                                        NavigationLink {
                                            ShareableView(for: media)
                                        } label: {
                                            Label("Share", systemImage: "square.and.arrow.up")
                                        }
                                        Divider()
                                        Button(role: .destructive) {
                                            context.delete(media)
                                        } label: {
                                            Label(
                                                deleteMenuItemText,
                                                systemImage: deleteMenuItemSymbol)
                                        }
                                    }
                                    .sensoryFeedback(.success, trigger: media.isFavorite)
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
            .padding()
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
            // Normally, a button does not go here. This is a workaround for a visual issue with
            // applying the .glassProminent ButtonStyle to a Menu.
            Button {
                return
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
            }
            .prominentButtonStyle(isEnabled: collectionFilterOption != .allMedia)
            .tint(collectionFilterOption == .allMedia ? nil : .physicalGreen)
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
