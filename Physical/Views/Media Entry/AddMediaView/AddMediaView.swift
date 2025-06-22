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
    @State private var newMedia = Media()
    @State private var searchResults: MusicItemCollection<Album> = []
    @State private var editingMediaDetails = false
    @State private var shouldShowMediaAddedNotification = false
    
    @FocusState private var searchFieldFocused: Bool
    
    var body: some View {
        ZStack {
            Color(UIColor.secondarySystemBackground)
                .ignoresSafeArea()
            
            List {
                Section {
                    TextField("Album Title", text: $newMedia.title)
                        .focused($searchFieldFocused)
                        .listRowBackground(Color(UIColor.tertiarySystemFill))
                } footer: {
                    if searchResults.isEmpty {
                        Text("Search for an album on Apple Music or enter the title and continue to manually add details.")
                    }
                }
                
                if !searchResults.isEmpty {
                    Section {
                        ForEach(searchResults) { album in
                            Button {
                                newMedia.updateWithInfo(from: album)
                                searchFieldFocused = false
                                editingMediaDetails = true
                            } label: {
                                SearchResultListItem(for: album)
                            }
                            .listRowBackground(Color(UIColor.systemBackground))
                        }
                    } header: {
                        Label("Search Results", systemImage: "magnifyingglass")
                            .labelStyle(.titleAndIcon)
                            .textCase(nil)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Add Media")
        .navigationDestination(isPresented: $editingMediaDetails) {
            @Bindable var newMedia = newMedia
            MediaDetailsEntryView(newMedia: $newMedia, isPresented: $editingMediaDetails)
        }
        .onChange(of: editingMediaDetails) {
            if !editingMediaDetails {
                newMedia = Media()
                showMediaAddedNotification()
            }
        }
        .onChange(of: newMedia.title) {
            if MusicAuthorization.currentStatus == .authorized {
                self.requestSearchResults(newMedia.title)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if shouldShowMediaAddedNotification {
                MediaAddedNotificationView()
                    .padding(.bottom, 48)
                    .transition(.push(from: .bottom))
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Continue") {
                    searchFieldFocused = false
                    editingMediaDetails = true
                }
                .disabled(newMedia.title.isEmpty)
            }
        }
    }
    
    private func showMediaAddedNotification() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                shouldShowMediaAddedNotification = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.5) {
            withAnimation {
                shouldShowMediaAddedNotification = false
            }
        }
    }
    
    private func requestSearchResults(_ entry: String) {
        Task {
            if entry.isEmpty {
                self.resetSearchResults()
            } else {
                do {
                    var searchRequest = MusicCatalogSearchRequest(term: entry, types: [Album.self])
                    searchRequest.limit = 5
                    let searchResponse = try await searchRequest.response()
                    
                    self.updateSearchResults(searchResponse, for: newMedia.title)
                } catch {
                    print("Search request failed with error: \(error).")
                    self.resetSearchResults()
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
