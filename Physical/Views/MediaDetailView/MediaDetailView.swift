//
//  MediaDetailView.swift
//  Physical
//
//  Created by Spencer Hartland on 7/19/23.
//

import SwiftUI

struct MediaDetailView: View {
    @Environment(\.screenSize) private var screenSize
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var media: Media
    @State private var isEditing: Bool = false
    
    init(media: Media) {
        self.media = media
    }
    
    var body: some View {
        List {
            // Album details
            Section {
                tracklist
            } header: {
                albumArtWithDetails
            } footer: {
                tracklistFooter
            }
            
            // Notes
            if !media.notes.isEmpty { notes }
        }
        .listStyle(.grouped)
        .scrollContentBackground(.hidden)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Label("Back", systemImage: "chevron.backward")
                        .labelStyle(.iconOnly)
                }
                .tint(nil)
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
    
    private var moreMenu: some View {
        Menu {
            Button {
                media.isFavorite.toggle()
            } label: {
                Label(
                    "Favorite",
                    systemImage: media.isFavorite ? "heart.fill" : "heart"
                )
            }
            Divider()
            Button {
                self.isEditing = true
            } label: {
                Label("Edit details", systemImage: "square.and.pencil")
            }
            Button {
                // TODO: Generate image to share
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            Divider()
            Button(role: .destructive) {
                modelContext.delete(media)
                dismiss()
            } label: {
                Label("Remove from Collection", systemImage: "trash")
                    .tint(.red)
            }
        } label: {
            Label("More", systemImage: "ellipsis")
                .labelStyle(.iconOnly)
                .frame(width: 18, height: 18)
                .foregroundStyle(Color.darkGreen)
        }
        .menuStyle(.button)
        .tint(nil)
    }
    
    private var albumArtWithDetails: some View {
        VStack {
            MediaImageCarousel(size: screenSize, albumArtworkURL: media.albumArtworkURL, imageKeys: media.imageKeys, mediaType: media.type)
            VStack {
                // Title
                Text(media.title)
                    .font(.title.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                // Artist
                Text(media.artist)
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(.bottom, 8)
            // Details
            Text("\(media.genre) · \(media.releaseDate, format: .dateTime.year()) · \(media.condition.rawValue)")
                .font(.system(.caption, weight: .medium))
                .foregroundStyle(.secondary)
                .padding(.bottom, 16)
        }
        .textCase(.none)
        .foregroundStyle(.primary)
    }
    
    private var tracklistFooter: some View {
        HStack(spacing: 32) {
            VStack(alignment: .leading) {
                Text("Released")
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundStyle(.secondary)
                Text("\(media.releaseDate, format: .dateTime.month().day().year())")
                    .font(.body)
            }
            
            VStack(alignment: .leading) {
                Text("Added to Collection")
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundStyle(.secondary)
                Text("\(media.dateAdded, format: .dateTime.month().day().year())")
                    .font(.body)
            }
        }
        .padding(.vertical)
    }
    
    private var tracklist: some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 16) {
            ForEach(Array(media.tracks.enumerated()), id: \.element) { trackIndex, trackTitle in
                GridRow {
                    Text("\(trackIndex + 1)")
                        .foregroundStyle(.secondary)
                        .gridColumnAlignment(.trailing)
                    HStack {
                        Text(trackTitle)
                            .foregroundStyle(.primary)
                            .gridColumnAlignment(.leading)
                        Spacer()
                    }
                }
                
                if let lastTrack = media.tracks.last,
                   trackTitle != lastTrack {
                    Divider()
                }
            }
        }
    }
    
    private var notes: some View {
        Section {
            Text(media.notes)
        } header: {
            Label("Notes", systemImage: "note.text")
                .labelStyle(.titleAndIcon)
                .textCase(nil)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .listRowSeparator(.hidden)
    }
}
