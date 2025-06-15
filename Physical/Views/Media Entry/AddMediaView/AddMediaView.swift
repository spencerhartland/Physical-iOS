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
    private let navTitle = "Add Media"
    private let searchFieldTitle = "Enter title"
    private let albumTitlePrompts = ["Art Angels", "Visions", "Syro", "Drukqs", "Post", "Homogenic", "Utopia", "KiCk i"]
    private let albumTitleFooterText = "Search for an album on Apple Music or enter the title and continue to manually add details."
    private let searchResultsHeaderSymbolName = "magnifyingglass"
    private let searchResultsHeaderText = "Search Results"
    private let continueButtonText = "Continue"
    
    @State private var newMedia = Media()
    @State private var searchResults: MusicItemCollection<Album> = []
    @State private var editingMediaDetails = false
    @State private var scanningBarcode = false
    @State private var shouldShowMediaAddedNotification = false
    
    // Animating prompts
    @State private var prompt = 0
    private let searchPromptTimer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
    
    @FocusState private var searchFieldFocused: Bool
    @Binding var rootViewSelectedTab: Int
    
    init(_ selectedTab: Binding<Int>) {
        self._rootViewSelectedTab = selectedTab
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.secondarySystemBackground)
                    .ignoresSafeArea()
                
                List {
                    Section {
                        TextField(albumTitlePrompts[prompt], text: $newMedia.title)
                            .focused($searchFieldFocused)
                            .listRowBackground(Color(UIColor.tertiarySystemFill))
                    } header: {
                        Text(searchFieldTitle)
                            .textCase(nil)
                            .font(.subheadline)
                            .fontWeight(.medium)
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
                                    searchFieldFocused = false
                                    editingMediaDetails = true
                                } label: {
                                    SearchResultListItem(for: album)
                                }
                                .listRowBackground(Color(UIColor.systemBackground))
                            }
                        } header: {
                            Label(searchResultsHeaderText, systemImage: searchResultsHeaderSymbolName)
                                .labelStyle(.titleAndIcon)
                                .textCase(nil)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(navTitle)
            .navigationDestination(isPresented: $editingMediaDetails) {
                @Bindable var newMedia = newMedia
                MediaDetailsEntryView(newMedia: $newMedia, isPresented: $editingMediaDetails)
            }
            .navigationDestination(isPresented: $scanningBarcode) {
                @Bindable var newMedia = newMedia
                BarcodeScanAlbumSearchView(newMedia: $newMedia, isPresented: $scanningBarcode)
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    // Barcode scanning
                    Button {
                        scanningBarcode = true
                    } label: {
                        Label("Scan", systemImage: "barcode.viewfinder")
                            .labelStyle(.titleAndIcon)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .tint(.lightGreen)
                    .foregroundStyle(Color.darkGreen)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    
                    // Manual entry
                    Button(continueButtonText) {
                        searchFieldFocused = false
                        editingMediaDetails = true
                    }
                    .disabled(newMedia.title.isEmpty)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .tint(.lightGreen)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .transition(.opacity)
                    .animation(.easeInOut, value: newMedia.title.isEmpty)
                }
            }
            .onChange(of: editingMediaDetails) {
                if !editingMediaDetails {
                    newMedia = Media()
                    showMediaAddedNotification()
                }
            }
            .onChange(of: scanningBarcode) {
                if !scanningBarcode {
                    newMedia = Media()
                    showMediaAddedNotification()
                }
            }
            .onChange(of: newMedia.title) {
                if MusicAuthorization.currentStatus == .authorized {
                    self.requestSearchResults(newMedia.title)
                }
            }
            .onReceive(searchPromptTimer) { _ in
                withAnimation(.smooth) {
                    self.prompt = self.prompt < albumTitlePrompts.count - 1 ? self.prompt + 1 : 0
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if shouldShowMediaAddedNotification {
                MediaAddedNotificationView()
                    .padding(.bottom, 48)
                    .transition(.push(from: .bottom))
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

#Preview {
    @Previewable @State var selected = 1
    
    AddMediaView($selected)
}
