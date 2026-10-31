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
    private let albumSearchDebounceDelay: TimeInterval = 0.33
    
    @Environment(\.dismissSearch) private var dismissSearch
    @Environment(\.colorScheme) private var colorScheme
    
    @FocusState private var albumTitleFieldIsFocused: Bool
    
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
                    "Add Media",
                    systemImage: "music.note.square.stack.fill",
                    description: Text("Enter an album title to continue.")
                )
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
            
            VStack {
                Spacer()
                
                TextField(
                    "Album Title",
                    text: $draft.title,
                    prompt: Text("Album Title")
                )
                .glassTextfieldStyle()
                .focused($albumTitleFieldIsFocused)
                .padding(albumTitleFieldIsFocused ? [.horizontal, .bottom] : [.horizontal])
            }
        }
        .onChange(of: draft.title) {
            if MusicAuthorization.currentStatus == .authorized {
                self.requestSearchResults(draft.title)
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Continue", systemImage: "chevron.forward") {
                    dismissSearch()
                    completion()
                }
                .prominentButtonStyle()
                .tint(.physicalGreen)
                .disabled(draft.title.isEmpty)
            }
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
