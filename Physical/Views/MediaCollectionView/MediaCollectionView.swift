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
    private let sortMenuButtonSymbolName = "ellipsis.circle"
    private static let appleMusicPreferenceKey = "shouldAskForAppleMusicAuthorization"
    private let appleMusicDisabledAlertTitle = "Apple Music access is disabled!"
    private let enableInSettingsButtonText = "Enable in Settings"
    private let dontAskAgainButtonText = "Don't ask again"
    private let notNowButtonText = "Not now"
    private let appleMusicDisabledAlertMessage = "Physical uses Apple Music to automatically populate information about new additions to your collection."
    
    @AppStorage(MediaCollectionView.appleMusicPreferenceKey) var shouldAskForAppleMusicAuthorization: Bool = true
    @Environment(\.openURL) private var openURL
    @Environment(\.modelContext) private var context
    
    @State private var musicAuthorizationStatus = MusicAuthorization.currentStatus
    @State private var musicAuthorizationDenied = false
    @State private var addingMedia = false
    
    @State private var organizer = CollectionOrganizer()
    @Query private var media: [Media]
    
    var body: some View {
        NavigationStack {
            MediaGrid(organizer.sections, thumbnailsOrnamented: (organizer.sorting == .byMediaType) ? false : true)
                .navigationTitle(navTitle)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                if shouldAskForAppleMusicAuthorization {
                                    checkForMusicAuthorization()
                                }
                                addingMedia.toggle()
                            } label: {
                                Label {
                                    Text(manualDetailsEntryText)
                                } icon: {
                                    Image(systemName: manualDetailsEntryButtonSymbolName)
                                }
                            }
                            
                            Button {
                                // Scan barcode
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
                        
                        filterAndSortMenu
                    }
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
                .sheet(isPresented: $addingMedia) {
                    AlbumTitleSearchView(isPresented: $addingMedia)
                }
        }
        .onAppear {
            organizer.makeSections(from: media)
        }
        .onChange(of: media) { _, _ in
            organizer.makeSections(from: media)
        }
        .onChange(of: organizer.filter) { _, _ in
            organizer.makeSections(from: media)
        }
        .onChange(of: organizer.sorting) { _, _ in
            organizer.makeSections(from: media)
        }
    }
    
    private var filterAndSortMenu: some View {
        Menu {
            Menu("Filter") {
                ForEach(CollectionFilter.allCases) { filter in
                    if filter != .allMedia {
                        Button {
                            organizer.filter = (organizer.filter == filter) ? .allMedia : filter
                        } label: {
                            Label {
                                Text(filter.rawValue)
                            } icon: {
                                if organizer.filter == filter {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }
            Menu("Sort") {
                ForEach(CollectionSorting.allCases) { sort in
                    Button {
                        organizer.sorting = sort
                    } label: {
                        Label {
                            Text(sort.rawValue)
                        } icon: {
                            if organizer.sorting == sort {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        } label: {
            Image(systemName: sortMenuButtonSymbolName)
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
