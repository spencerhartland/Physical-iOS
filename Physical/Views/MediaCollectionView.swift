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
    private let menuDisclosureButtonSymbolName = "ellipsis.circle"
    private static let appleMusicPreferenceKey = "shouldAskForAppleMusicAuthorization"
    private let appleMusicDisabledAlertTitle = "Apple Music access is disabled!"
    private let enableInSettingsButtonText = "Enable in Settings"
    private let dontAskAgainButtonText = "Don't ask again"
    private let notNowButtonText = "Not now"
    private let appleMusicDisabledAlertMessage = "Physical uses Apple Music to automatically populate information about new additions to your collection."
    
    @AppStorage(MediaCollectionView.appleMusicPreferenceKey) var shouldAskForAppleMusicAuthorization: Bool = true
    @Environment(\.modelContext) var modelContext
    @Environment(\.openURL) private var openURL
    @Query private var collection: [Media]
    
    @State private var musicAuthorizationStatus = MusicAuthorization.currentStatus
    @State private var musicAuthorizationDenied = false
    @State private var addingMedia = false
    
    var body: some View {
        NavigationStack {
            Text("Testing")
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
                        
                        Button {
                            // Trigger menu to sort collection
                        } label: {
                            Image(systemName: menuDisclosureButtonSymbolName)
                        }
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
                    AlbumTitleSearchView()
                }
        }
    }
    
    private func checkForMusicAuthorization() {
        switch MusicAuthorization.currentStatus {
        case .notDetermined:
            musicAuthorizationDenied = false
            Task {
                let musicAuthStatus = await MusicAuthorization.request()
                self.update(with: musicAuthStatus)
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
