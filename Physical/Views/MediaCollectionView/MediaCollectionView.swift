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
    private let filterAndSortMenuButtonSymbolName = "ellipsis"
    private let filterMenuTitle = "Filter"
    private let sortMenuTitle = "Sort"
    private let appleMusicDisabledAlertTitle = "Apple Music access is disabled!"
    private let enableInSettingsButtonText = "Enable in Settings"
    private let dontAskAgainButtonText = "Don't ask again"
    private let notNowButtonText = "Not now"
    private let appleMusicDisabledAlertMessage = "Physical uses Apple Music to automatically populate information about new additions to your collection."
    private let checkmarkSymbolName = "checkmark"
    private let collectionEmptySymbolName = "music.quarternote.3"
    private let collectionEmptyTitle = "No Media"
    private let collectionEmptyDecription = "Add media to build your digital collection."
    private let collectionEmptyAddMediaButtonSymbolName = "plus"
    private let collectionEmptyAddMediaButtonTitle = "Add Media"
    
    @AppStorage(StorageKeys.shouldAskForAppleMusicAuthorization) var shouldAskForAppleMusicAuthorization: Bool = true
    @AppStorage(StorageKeys.preferredCollectionSortOption) var preferredCollectionSortOption: String = CollectionSorting.recentlyAdded.rawValue
    
    @Environment(\.openURL) private var openURL
    @Environment(\.modelContext) private var context
    
    @State private var musicAuthorizationStatus = MusicAuthorization.currentStatus
    @State private var musicAuthorizationDenied = false
    @State private var collectionSortOption: CollectionSorting = .recentlyAdded
    @State private var collectionFilterOption: CollectionFilter = .allMedia
    @State private var currentSearch: String = ""
    
    @Query private var media: [Media]
    
    @Binding var selectedTab: Int
    
    init(_ selectedTab: Binding<Int>) {
        self._selectedTab = selectedTab
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.secondarySystemBackground)
                    .ignoresSafeArea()
                
                if media.isEmpty {
                    collectionIsEmptyView
                } else {
                    Collection(media, sort: collectionSortOption, filter: collectionFilterOption, search: currentSearch)
                }
            }
            .navigationTitle(collectionFilterOption == .allMedia ? navTitle : collectionFilterOption.rawValue)
            .toolbarTitleDisplayMode(.large)
            .toolbar {
                filterAndSortMenu
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
        }
        .searchable(text: $currentSearch)
        .onAppear { rememberSortOption() }
        .onChange(of: collectionSortOption) { oldValue, newValue in
            memorizeSortOptionIfChanged(oldValue, newValue)
        }
    }
    
    private var filterAndSortMenu: some View {
        Menu {
            sortMenu
                .tint(.darkGreen)
            filterMenu
                .tint(.darkGreen)
        } label: {
            Label("Filter and Sort", systemImage: filterAndSortMenuButtonSymbolName)
                .labelStyle(.iconOnly)
                .frame(width: 18, height: 18)
        }
        .menuStyle(.button)
        .buttonStyle(.bordered)
        .buttonBorderShape(.circle)
        .tint(collectionFilterOption == .allMedia ? nil : Color.lightGreen)
        .foregroundStyle(collectionFilterOption == .allMedia ? Color.darkGreen : Color.darkGreen)
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
    
    private var collectionIsEmptyView: some View {
        ContentUnavailableView {
            Label(collectionEmptyTitle, systemImage: collectionEmptySymbolName)
        } description: {
            Text(collectionEmptyDecription)
        } actions: {
            Button {
                selectedTab = 1
            } label: {
                Label(
                    collectionEmptyAddMediaButtonTitle,
                    systemImage: collectionEmptyAddMediaButtonSymbolName
                )
                .labelStyle(.titleAndIcon)
                .padding(4)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .tint(.lightGreen)
            .foregroundStyle(Color.darkGreen)
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
