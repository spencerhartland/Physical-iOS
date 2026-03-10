//
//  MediaDetailView.swift
//  Physical
//
//  Created by Spencer Hartland on 7/19/23.
//

import SwiftUI

struct MediaDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var media: Media
    @State private var isEditing: Bool = false
    @State private var isSharing: Bool = false
    
    init(media: Media) {
        self.media = media
    }
    
    var body: some View {
        List {
            // Album details
            Section {
                tracklist
                    .listRowBackground(EmptyView())
            } header: {
                albumArtWithDetails
            } footer: {
                tracklistFooter
                    .foregroundStyle(.primary)
            }
            .listRowSeparator(.hidden)
            
            // Notes
            if !media.notes.isEmpty {
                notes
                    .listRowBackground(EmptyView())
            }
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
            MediaDetailsEntryView(media: media) { isEditing = false }
        }
        .navigationDestination(isPresented: $isSharing) { ShareableView(for: media) }
    }
    
    private var moreMenu: some View {
        Menu {
            Button {
                media.isFavorite.toggle()
            } label: {
                Label(
                    media.isFavorite ? "Undo favorite" : "Favorite",
                    systemImage: media.isFavorite ? "heart.fill" : "heart.slash.fill"
                )
            }
            Divider()
            Button {
                self.isEditing = true
            } label: {
                Label("Edit details", systemImage: "square.and.pencil")
            }
            Button {
                self.isSharing = true
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
                .foregroundStyle(.physicalGreen)
        }
        .menuStyle(.button)
        .tint(nil)
    }
    
    private var albumArtWithDetails: some View {
        VStack {
            MediaImageCarousel(
                for: media.type,
                with: media.albumArtworkURL,
                and: media.color)
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
                    .foregroundStyle(.primary)
            }
            
            VStack(alignment: .leading) {
                Text("Added to Collection")
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundStyle(.secondary)
                Text("\(media.dateAdded, format: .dateTime.month().day().year())")
                    .font(.body)
                    .foregroundStyle(.primary)
            }
        }
        .padding(.vertical)
    }
    
    private var tracklist: some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 16) {
            Divider()
            
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
                
                Divider()
                    .gridColumnAlignment(.listRowSeparatorLeading)
            }
        }
    }
    
    private var notes: some View {
        HStack {
            VStack(alignment: .leading, spacing: 16) {
                Label("Notes", systemImage: "note.text")
                    .labelStyle(.titleAndIcon)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Text(media.notes)
            }
            .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .listRowSeparator(.hidden)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        }
    }
}
