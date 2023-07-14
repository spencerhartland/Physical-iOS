//
//  AlbumTitleSearchView.swift
//  Physical
//
//  Created by Spencer Hartland on 7/13/23.
//

import SwiftUI
import MusicKit

struct AlbumTitleSearchView: View {
    private let navTitle = "Add Media"
    private let albumTitleText = "Album Title"
    private let albumTitlePrompt = "Miss Anthropocene"
    private let albumTitleFooterText = "Search for and fetch album information from Apple Music or enter the title and continue to manually add details."
    private let continueButtonText = "Continue"
    
    @Binding var albumTitle: String
    var doneSearching: () -> Void
    @State private var searchResults: MusicItemCollection<Album> = []
    
    var body: some View {
        List {
            Section {
                TextField(albumTitlePrompt, text: $albumTitle)
            } header: {
                Text(albumTitleText)
            } footer: {
                if searchResults.isEmpty {
                    Text(albumTitleFooterText)
                }
            }
            
            ForEach(searchResults) { album in
                Text("\(album.title) by \(album.artistName)")
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button(continueButtonText) {
                    doneSearching()
                }
                .disabled(albumTitle.isEmpty)
                .padding()
            }
        }
        .navigationTitle(navTitle)
        .onChange(of: albumTitle) {
            if MusicAuthorization.currentStatus == .authorized {
                self.requestSearchResults(albumTitle)
            }
        }
    }
    
    private func requestSearchResults(_ entry: String) {
        Task {
            if entry.isEmpty {
                await self.resetSearchResults()
            } else {
                do {
                    var searchRequest = MusicCatalogSearchRequest(term: entry, types: [Album.self])
                    searchRequest.limit = 5
                    let searchResponse = try await searchRequest.response()
                    
                    await self.updateSearchResults(searchResponse, for: albumTitle)
                } catch {
                    print("Search request failed with error: \(error).")
                    await self.resetSearchResults()
                }
            }
        }
    }
    
    @MainActor
    private func updateSearchResults(_ searchResponse: MusicCatalogSearchResponse, for searchTerrm: String) {
        if self.albumTitle == searchTerrm {
            self.searchResults = searchResponse.albums
        }
    }
    
    @MainActor
    private func resetSearchResults() {
        self.searchResults = []
    }
}
