//
//  MediaDetailView.swift
//  Physical
//
//  Created by Spencer Hartland on 7/19/23.
//

import SwiftUI

struct MediaDetailView: View {
    private let moreMenuTitle = "More"
    private let favoriteMenuItemText = "Favorite"
    private let editMenuItemText = "Edit details"
    private let shareMenuItemText = "Share"
    private let deleteMenuItemText = "Remove from Collection"
    private let releaseDateText = "Released on"
    private let dateAddedText = "Added to Collection on"
    private let conditionStringFormatSpecifier = "Condition: %@"
    private let notesSectionHeaderText = "Notes"
    
    private let moreMenuSymbol = "ellipsis"
    private let notFavoriteMenuItemSymbol = "heart"
    private let favoriteMenuItemSymbol = "heart.fill"
    private let editMenuItemSymbol = "square.and.pencil"
    private let shareMenuItemSymbol = "square.and.arrow.up"
    private let deleteMenuItemSymbol = "trash"
    private let compactDiscSymbol = "opticaldisc.fill"
    private let horizontalDetailsSeparatorSymbol = "circle.fill"
    private let notesSectionSymbol = "note.text"
    
    @Environment(\.screenSize) private var screenSize
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var media: Media
    @State private var isEditing: Bool = false
    
    init(media: Media) {
        self.media = media
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.secondarySystemBackground)
                .ignoresSafeArea()
            
            List {
                // Album details
                Section {
                    tracklist
                } header: {
                    albumArtWithDetails
                }
                .listRowBackground(Color(UIColor.secondarySystemBackground))
                
                // More info
                Section {
                    tracklistFooter
                } header: {
                    Label("Info", systemImage: "info.square")
                        .labelStyle(.titleAndIcon)
                        .textCase(nil)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color(UIColor.secondarySystemBackground))
                
                // Notes
                if !media.notes.isEmpty { notes }
            }
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
            .background(Color(UIColor.systemGroupedBackground))
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .frame(width: 18, height: 18)
                    }
                    .tint(nil)
                    .foregroundStyle(Color.darkGreen)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                    .fontWeight(.medium)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    moreMenu
                }
            }
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $isEditing) {
                @Bindable var newMedia = media
                MediaDetailsEntryView(newMedia: $newMedia, isPresented: $isEditing)
            }
        }
    }
    
    private var moreMenu: some View {
        Menu {
            Button {
                media.isFavorite.toggle()
            } label: {
                Label(favoriteMenuItemText, systemImage: media.isFavorite ? favoriteMenuItemSymbol : notFavoriteMenuItemSymbol)
            }
            Divider()
            Button {
                self.isEditing = true
            } label: {
                Label(editMenuItemText, systemImage: editMenuItemSymbol)
            }
            Button {
                // Generate image to share
            } label: {
                Label(shareMenuItemText, systemImage: shareMenuItemSymbol)
            }
            Divider()
            Button(role: .destructive) {
                modelContext.delete(media)
                dismiss()
            } label: {
                Label(deleteMenuItemText, systemImage: deleteMenuItemSymbol)
                    .tint(.red)
            }
        } label: {
            Label(moreMenuTitle, systemImage: moreMenuSymbol)
                .labelStyle(.iconOnly)
                .frame(width: 18, height: 18)
                .foregroundStyle(Color.darkGreen)
        }
        .menuStyle(.button)
        .buttonStyle(.bordered)
        .buttonBorderShape(.circle)
        .tint(nil)
    }
    
    private var albumArtWithDetails: some View {
        VStack {
            MediaImageCarousel(size: screenSize, albumArtworkURL: media.albumArtworkURL, imageKeys: media.imageKeys)
            VStack {
                // Title
                Text(media.title)
                    .font(.title.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                // Artist
                Text(media.artist)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(.bottom, 8)
            // Details
            HStack {
                HStack(spacing: 4) {
                    mediaTypeSymbol
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 12)
                    Text(media.type.rawValue)
                }
                Image(systemName: horizontalDetailsSeparatorSymbol)
                    .font(.system(size: 3))
                Text(media.releaseDate, format: .dateTime.year())
                Image(systemName: horizontalDetailsSeparatorSymbol)
                    .font(.system(size: 3))
                Text(media.genre)
            }
            .font(.system(.caption, weight: .medium))
            .foregroundStyle(.secondary)
            .padding(.bottom, 16)
        }
        .textCase(.none)
        .foregroundStyle(.primary)
    }
    
    private var tracklistFooter: some View {
        Grid(alignment: .topLeading, horizontalSpacing: 32, verticalSpacing: 16) {
            GridRow {
                VStack(alignment: .leading) {
                    Text("Released")
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .foregroundStyle(.secondary)
                    Text("\(media.releaseDate, format: .dateTime.month().day().year())")
                }
                
                VStack(alignment: .leading) {
                    Text("Added to Collection")
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .foregroundStyle(.secondary)
                    Text("\(media.dateAdded, format: .dateTime.month().day().year())")
                }
            }
            
            GridRow {
                VStack(alignment: .leading) {
                    Text("Condition")
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .foregroundStyle(.secondary)
                    Text(media.condition.rawValue)
                }
                
                Spacer()
            }
        }
    }
    
    private var tracklist: some View {
        ForEach(Array(media.tracks.enumerated()), id: \.element) { trackNum, trackTitle in
            HStack(spacing: 16) {
                Text("\(trackNum + 1)")
                    .foregroundStyle(.secondary)
                Text(trackTitle)
                    .lineLimit(1)
            }
            .padding([.vertical, .leading], 6)
        }
    }
    
    private var notes: some View {
        Section {
            Text(media.notes)
        } header: {
            Label(notesSectionHeaderText, systemImage: notesSectionSymbol)
                .labelStyle(.titleAndIcon)
                .textCase(nil)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color(UIColor.systemGroupedBackground))
    }
    
    private var mediaTypeSymbol: Image {
        switch media.type {
        case .vinylRecord:
            return Image(.vinylRecord)
        case .compactDisc:
            return Image(systemName: compactDiscSymbol)
        case .compactCassette:
            return Image(.compactCassette)
        }
    }
}
