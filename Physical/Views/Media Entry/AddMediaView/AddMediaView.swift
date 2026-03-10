//
//  AlbumTitleSearchView.swift
//  Physical
//
//  Created by Spencer Hartland on 7/13/23.
//

import SwiftUI
import UIKit
import MusicKit

struct AddMediaView: View {
    // String constants
    private let noSearchResultsTitle: String = "Add Media"
    private let noSearchResultsDescription: String = "Enter an album title to continue."
    private let albumTitleTextfieldPrompt: String = "Album Title"
    private let continueButtonTitle: String = "Continue"
    
    // Symbols
    private let noSearchResultsSymbolName: String = "music.note.square.stack.fill"
    private let continueButtonSymbolName: String = "arrow.forward"
    
    // Other constants
    private let albumSearchDebounceDelay: TimeInterval = 0.33
    
    @Environment(\.dismissSearch) private var dismissSearch
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var albumSearchRequest: DispatchWorkItem?
    @State private var searchResults: MusicItemCollection<Album> = []
    
    @Bindable var draft: MediaDraft
    
    private var completion: () -> Void
    
    init(draft: Bindable<MediaDraft>, _ completion: @escaping () -> Void) {
        self._draft = draft
        self.completion = completion
    }
    
    var body: some View {
        ZStack {
            if searchResults.isEmpty {
                ContentUnavailableView(
                    noSearchResultsTitle,
                    systemImage: noSearchResultsSymbolName,
                    description: Text(noSearchResultsDescription))
            }
            if !searchResults.isEmpty {
                List {
                    ForEach(searchResults) { album in
                        Button {
                            draft.updateWithInfo(from: album)
                            dismissSearch()
                            completion()
                        } label: {
                            SearchResultListItem(for: album)
                        }
                        .alignmentGuide(.listRowSeparatorLeading) { dimensions in
                            return dimensions[.leading]
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .searchable(text: $draft.title, prompt: albumTitleTextfieldPrompt)
        .searchPresentationToolbarBehavior(.avoidHidingContent)
        .onChange(of: draft.title) {
            if MusicAuthorization.currentStatus == .authorized {
                self.requestSearchResults(draft.title)
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(continueButtonTitle, systemImage: continueButtonSymbolName) {
                    dismissSearch()
                    completion()
                }
                .disabled(draft.title.isEmpty)
            }
        }
        .onAppear {
            UISearchBar.appearance().setImage(UIImage(), for: .search, state: .normal)
        }
    }
    
    private func requestSearchResults(_ entry: String) {
        albumSearchRequest?.cancel()
        albumSearchRequest = DispatchWorkItem {
            Task {
                if entry.isEmpty {
                    self.resetSearchResults()
                } else {
                    do {
                        var searchRequest = MusicCatalogSearchRequest(
                            term: entry,
                            types: [Album.self])
                        searchRequest.limit = 5
                        let searchResponse = try await searchRequest.response()
                        
                        self.updateSearchResults(searchResponse, for: draft.title)
                    } catch {
                        print("Search request failed with error: \(error).")
                        self.resetSearchResults()
                    }
                }
            }
            albumSearchRequest = nil
        }
        if let albumSearchRequest = albumSearchRequest {
            DispatchQueue.main.asyncAfter(
                deadline: .now() + albumSearchDebounceDelay,
                execute: albumSearchRequest)
        }
    }
    
    @MainActor
    private func updateSearchResults(
        _ searchResponse: MusicCatalogSearchResponse,
        for searchTerm: String) {
            if self.draft.title == searchTerm {
                self.searchResults = searchResponse.albums
            }
        }
    
    @MainActor
    private func resetSearchResults() {
        self.searchResults = []
    }
}
