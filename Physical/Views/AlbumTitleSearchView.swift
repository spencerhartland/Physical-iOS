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
    
    
    @State private var newMedia = Media()
    @State private var searchResults: MusicItemCollection<Album> = []
    @State private var doneSearching = false
    
    // Animating prompts
    @State private var prompt = 0
    private let timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
    
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
                                updateMediaWithInfo(from: album)
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
                MediaDetailsEntryView(newMedia: $newMedia)
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
    
    private func updateMediaWithInfo(from album: Album) {
        newMedia.title = album.title
        newMedia.artist = album.artistName
        newMedia.releaseDate = album.releaseDate ?? .now
        if let url = getArtworkURLString(from: album.artwork) {
            newMedia.images = [url]
        }
        Task {
            newMedia.tracks = await fetchTracks(from: album)
        }
    }
    
    private func fetchTracks(from album: Album) async -> [String] {
        do {
            let detailedAlbum = try await album.with([.tracks])
            guard let tracks = detailedAlbum.tracks else {
                print("Error while unwrapping collection of tracks.")
                return []
            }
            var tracksArray = [String]()
            for track in tracks {
                tracksArray.append(track.title)
            }
            return tracksArray
        } catch {
            print("Error getting tracks: \(error.localizedDescription)")
            return []
        }
    }
    
    private func getArtworkURLString(from artwork: Artwork?) -> String? {
        guard let artwork = artwork,
              let url = artwork.url(width: 1080, height: 1080) else {
            return nil
        }
        return url.absoluteString
    }
}
