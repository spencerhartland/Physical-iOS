//
//  MediaDetailsEntryView.swift
//  Vinyls
//
//  Created by Spencer Hartland on 7/9/23.
//

import SwiftUI
import MusicKit

struct MediaDetailsEntryView: View {
    private let navTitle = "Review Details"
    private let albumTitleText = "Album Title"
    private let albumTitlePrompt = "What's the album's title?"
    private let albumArtistText = "Album Artist"
    private let albumArtistPrompt = "Who made the album?"
    private let albumReleaseDateText = "Album Release Date"
    private let albumReleaseDatePrompt = "When was it released?"
    private let mediaTypeText = "Media Type"
    private let mediaTypePrompt = "Vinyl Record, CD, or Cassette?"
    private let mediaConditionText = "Media Condition"
    private let mediaConditionPrompt = "What condition is it in?"
    
    @State private var doneSearching = false
    @State private var newMedia = Media()
    
    var body: some View {
        if doneSearching {
            NavigationStack {
                GeometryReader { geo in
                    ScrollView {
                        // Photos
                        PhotoSelectionView()
                            .listRowBackground(Color.clear)
                            .frame(width: geo.size.width)
                        List {
                            // Title
                            TextEntryListItemView(header: albumTitleText, prompt: albumTitlePrompt, input: $newMedia.title)
                            // Artist
                            TextEntryListItemView(header: albumArtistText, prompt: albumArtistPrompt, input: $newMedia.artist)
                            // Release Date
                            DateEntryListItemView(header: albumReleaseDateText, prompt: albumReleaseDatePrompt, input: $newMedia.releaseDate)
                            // Media Type
                            MediaTypeSelectionListItemView(header: mediaTypeText, prompt: mediaTypePrompt, input: $newMedia.type)
                            // Condition
                            MediaConditionSelectionListItemView(header: mediaConditionText, prompt: mediaConditionPrompt, input: $newMedia.condition)
                        }
                        .scrollDisabled(true)
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                    }
                }
            }
            .navigationTitle(navTitle)
        } else {
            AlbumTitleEntryView(newMedia: $newMedia, doneSearching: $doneSearching)
        }
    }
}

fileprivate struct AlbumTitleEntryView: View {
    private let navTitle = "Add Media"
    private let albumTitleText = "Album Title"
    private let albumTitlePrompt = "What's the album's title?"
    private let albumTitleFooterText = "Search for and fetch album information from Apple Music or enter the title and continue to manually add details."
    private let continueButtonText = "Continue"
    
    @Binding var newMedia: Media
    @Binding var doneSearching: Bool
    @State private var searchResults: MusicItemCollection<Album> = []
    
    var body: some View {
        List {
            TextEntryListItemView(
                header: albumTitleText,
                prompt: albumTitlePrompt,
                footer: searchResults.isEmpty ? albumTitleFooterText : nil,
                input: $newMedia.title
            )
            ForEach(searchResults) { album in
                Text("\(album.title) by \(album.artistName)")
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button(continueButtonText) {
                    doneSearching.toggle()
                }
                .disabled(newMedia.title.isEmpty)
                .padding()
            }
        }
        .navigationTitle(navTitle)
        .onChange(of: newMedia.title) {
            if MusicAuthorization.currentStatus == .authorized {
                self.requestSearchResults(newMedia.title)
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
                    
                    await self.updateSearchResults(searchResponse, for: self.newMedia.title)
                } catch {
                    print("Search request failed with error: \(error).")
                    await self.resetSearchResults()
                }
            }
        }
    }
    
    @MainActor
    private func updateSearchResults(_ searchResponse: MusicCatalogSearchResponse, for searchTerrm: String) {
        if self.newMedia.title == searchTerrm {
            self.searchResults = searchResponse.albums
        }
    }
    
    @MainActor
    private func resetSearchResults() {
        self.searchResults = []
    }
}
