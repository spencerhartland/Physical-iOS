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
    private let albumTitlePrompts = ["Miss Anthropocene", "Art Angels", "Visions", "Halfaxa", "Geidi Primes", "Homogenic", "Utopia", "KiCk i"]
    private let albumTitleFooterText = "Search for and fetch album information from Apple Music or enter the title and continue to manually add details."
    private let searchResultsHeaderText = "Search Results"
    private let continueButtonText = "Continue"
    
    @Binding var addingMedia: Bool
    
    @Bindable private var newMedia = Media()
    @State private var searchResults: MusicItemCollection<Album> = []
    @State private var doneSearching = false
    
    // Animating prompts
    @State private var prompt = 0
    private let timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
    
    init(isPresented: Binding<Bool>) {
        self._addingMedia = isPresented
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField(albumTitlePrompts[prompt], text: $newMedia.title)
                } header: {
                    Text(albumTitleText)
                } footer: {
                    if searchResults.isEmpty {
                        Text(albumTitleFooterText)
                    }
                }
                
                if !searchResults.isEmpty {
                    Section {
                        ForEach(searchResults) { album in
                            Button {
                                newMedia.updateWithInfo(from: album)
                                doneSearching = true
                            } label: {
                                SearchResultListItem(for: album)
                            }
                        }
                    } header: {
                        Text(searchResultsHeaderText)
                    }
                }
            }
            .navigationTitle(navTitle)
            .navigationDestination(isPresented: $doneSearching) {
                MediaDetailsEntryView(newMedia: $newMedia, isPresented: $addingMedia)
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(continueButtonText) {
                        doneSearching = true
                    }
                    .disabled(newMedia.title.isEmpty)
                }
            }
            .onChange(of: newMedia.title) {
                if MusicAuthorization.currentStatus == .authorized {
                    self.requestSearchResults(newMedia.title)
                }
            }
            .onReceive(timer) { _ in
                withAnimation(.smooth) {
                    self.prompt = self.prompt < albumTitlePrompts.count - 1 ? self.prompt + 1 : 0
                }
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
                    
                    await self.updateSearchResults(searchResponse, for: newMedia.title)
                } catch {
                    print("Search request failed with error: \(error).")
                    await self.resetSearchResults()
                }
            }
        }
    }
    
    @MainActor
    private func updateSearchResults(_ searchResponse: MusicCatalogSearchResponse, for searchTerm: String) {
        if self.newMedia.title == searchTerm {
            self.searchResults = searchResponse.albums
        }
    }
    
    @MainActor
    private func resetSearchResults() {
        self.searchResults = []
    }
}
