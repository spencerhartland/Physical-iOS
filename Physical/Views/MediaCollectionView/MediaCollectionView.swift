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
    private let navTitle = "Collection"
    private let manualDetailsEntryText = "Enter manually"
    private let barcodeDetailsEntryText = "Scan barcode"
    private let addMediaButtonSymbolName = "plus"
    private let manualDetailsEntryButtonSymbolName = "character.cursor.ibeam"
    private let barcodeButtonSymbolName = "barcode.viewfinder"
    private let filterAndSortMenuButtonFilterEnabledSymbolName = "ellipsis.circle.fill"
    private let filterAndSortMenuButtonFilterDisabledSymbolName = "ellipsis.circle"
    private let filterMenuTitle = "Filter"
    private let sortMenuTitle = "Sort"
    private let appleMusicDisabledAlertTitle = "Apple Music access is disabled!"
    private let enableInSettingsButtonText = "Enable in Settings"
    private let dontAskAgainButtonText = "Don't ask again"
    private let notNowButtonText = "Not now"
    private let appleMusicDisabledAlertMessage = "Physical uses Apple Music to automatically populate information about new additions to your collection."
    private let checkmarkSymbolName = "checkmark"
    
    @AppStorage(StorageKeys.shouldAskForAppleMusicAuthorization) var shouldAskForAppleMusicAuthorization: Bool = true
    @AppStorage(StorageKeys.preferredCollectionSortOption) var preferredCollectionSortOption: String = CollectionSorting.recentlyAdded.rawValue
    
    @Environment(\.openURL) private var openURL
    @Environment(\.modelContext) private var context
    
    @State private var musicAuthorizationStatus = MusicAuthorization.currentStatus
    @State private var musicAuthorizationDenied = false
    @State private var addingMediaUsingManualEntry = false
    @State private var addingMediaUsingBarcodeScanning = false
    @State private var collectionSortOption: CollectionSorting = .recentlyAdded
    @State private var collectionFilterOption: CollectionFilter = .allMedia
    @State private var currentSearch: String = ""
    
    @Query private var media: [Media]
    
    var body: some View {
        NavigationStack {
            Collection(media, sort: collectionSortOption, filter: collectionFilterOption, search: currentSearch)
                .navigationTitle(collectionFilterOption == .allMedia ? navTitle : collectionFilterOption.rawValue)
                .toolbar {
                    toolbarItems
                }
                .alert(appleMusicDisabledAlertTitle, isPresented: $musicAuthorizationDenied) {
                    Button(enableInSettingsButtonText) {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            openURL(settingsURL)
                        }
                    }
                    Button(dontAskAgainButtonText) {
                        shouldAskForAppleMusicAuthorization = false
                    }
                    Button(notNowButtonText, role: .cancel) {
                        return
                    }
                } message: {
                    Text(appleMusicDisabledAlertMessage)
                }
                .sheet(isPresented: $addingMediaUsingManualEntry) {
                    AlbumTitleSearchView(isPresented: $addingMediaUsingManualEntry)
                }
                .sheet(isPresented: $addingMediaUsingBarcodeScanning) {
                    BarcodeScanAlbumSearchView(isPresented: $addingMediaUsingBarcodeScanning)
                }
        }
        .searchable(text: $currentSearch)
        .onAppear { rememberSortOption() }
        .onChange(of: collectionSortOption) { oldValue, newValue in
            memorizeSortOptionIfChanged(oldValue, newValue)
        }
    }
    
    private var toolbarItems: ToolbarItemGroup<some View> {
        ToolbarItemGroup(placement: .topBarTrailing) {
            addMediaMenu
            filterAndSortMenu
        }
    }
    
    private var addMediaMenu: some View {
        Menu {
            Button {
                if shouldAskForAppleMusicAuthorization {
                    checkForMusicAuthorization()
                }
                addingMediaUsingManualEntry.toggle()
            } label: {
                Label {
                    Text(manualDetailsEntryText)
                } icon: {
                    Image(systemName: manualDetailsEntryButtonSymbolName)
                }
            }
            
            Button {
                if shouldAskForAppleMusicAuthorization {
                    checkForMusicAuthorization()
                }
                addingMediaUsingBarcodeScanning.toggle()
            } label: {
                Label {
                    Text(barcodeDetailsEntryText)
                } icon: {
                    Image(systemName: barcodeButtonSymbolName)
                }
            }
        } label: {
            Image(systemName: addMediaButtonSymbolName)
        }
    }
    
    private var filterAndSortMenu: some View {
        Menu {
            sortMenu
            filterMenu
        } label: {
            Image(systemName: collectionFilterOption == .allMedia ? filterAndSortMenuButtonFilterDisabledSymbolName : filterAndSortMenuButtonFilterEnabledSymbolName)
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
                                Image(systemName: checkmarkSymbolName)
                            }
                        }
                    }
                }
            }
        } label: {
            Text(filterMenuTitle)
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
                            Image(systemName: checkmarkSymbolName)
                        }
                    }
                }
            }
        } label: {
            Text(sortMenuTitle)
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
