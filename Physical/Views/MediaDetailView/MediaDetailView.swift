//
//  MediaDetailView.swift
//  Physical
//
//  Created by Spencer Hartland on 7/19/23.
//

import PhysicalMediaKit
import SwiftUI
import SwiftData

struct MediaDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var media: Media
    @State private var draft: MediaDraft
    @State private var isEditing: Bool = false
    @State private var isSharing: Bool = false
    
    private var bgColor: Color { media.dominantColor ?? Color(uiColor: .systemBackground) }
    
    let allowsNavigationBackwards: Bool
    let onDismiss: (() -> Void)?
    
    init(
        for media: Media,
        allowsNavigationBackwards: Bool = true,
        _ onDismiss: (() -> Void)? = nil
    ) {
        self.media = media
        self.draft = MediaDraft(from: media)
        self.allowsNavigationBackwards = allowsNavigationBackwards
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        List {
            Group {
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
            .padding(allowsNavigationBackwards ? [] : [.horizontal])
        }
        .listStyle(.grouped)
        .scrollContentBackground(.hidden)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            if allowsNavigationBackwards {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onDismiss?()
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
            } else {
                if #available(anyAppleOS 26.0, *) {
                    ToolbarSpacer(.fixed, placement: .topBarTrailing)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    moreMenu
                }
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $isEditing) {
            MediaDetailsEntryView(draft: $draft) {
                Task {
                    media.applyChanges(from: draft)
                    
                    if let artworkURL = media.albumArtworkURL,
                       let artwork = await PhysicalMedia.albumArtwork(from: artworkURL) {
                        let colors = await DominantColorsCalculator.dominantColors(in: artwork)
                        media.dominantColors = colors
                    }
                    
                    isEditing = false
                }
            }
        }
        .navigationDestination(isPresented: $isSharing) { ShareableView(for: media) }
        .onHingeOpen { if allowsNavigationBackwards { dismiss() } }
        .task(id: media) {
            guard media.dominantColors.isEmpty else { return }
            
            if let artworkURL = media.albumArtworkURL,
               let artwork = await PhysicalMedia.albumArtwork(from: artworkURL) {
                let colors = await DominantColorsCalculator.dominantColors(in: artwork)
                media.dominantColors = colors
                try? modelContext.save()
            }
        }
        .background {
            Rectangle()
                .fill(bgColor.gradient)
                .ignoresSafeArea()
        }
        .foregroundStyle(.contrasting(with: bgColor))
    }
    
    private var moreMenu: some View {
        Menu {
            Button {
                media.isFavorite.toggle()
                
                if media.isFavorite {
                    Task { await WidgetHelper.prepareFavoritesForWidget([media]) }
                }
                
                try? modelContext.save()
                WidgetHelper.reloadTimelines()
            } label: {
                Label(
                    media.isFavorite ? "Undo favorite" : "Favorite",
                    systemImage: media.isFavorite ? "heart.slash.fill" : "heart.fill"
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
                try? modelContext.save()
                WidgetHelper.reloadTimelines()
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
            // 3D model / images
            MediaImageCarousel(for: media)
                .padding(.bottom, 16)
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
            TrackSeparator(.contrasting(with: bgColor))
            
            ForEach(Array(media.tracks.enumerated()), id: \.offset) { trackIndex, trackTitle in
                GridRow {
                    Text("\(trackIndex + 1)")
                        .foregroundStyle(.secondary)
                        .gridColumnAlignment(.trailing)
                    
                    HStack {
                        Text(trackTitle)
                        Spacer()
                    }
                    .foregroundStyle(.primary)
                    .gridColumnAlignment(.leading)
                }
                
                if media.tracks.index(after: trackIndex) != media.tracks.endIndex {
                    GridRow {
                        Color.clear.frame(width: 0, height: 0)
                        TrackSeparator(.contrasting(with: bgColor))
                    }
                }
            }
            
            TrackSeparator(.contrasting(with: bgColor))
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
    
    private struct TrackSeparator<Style: ShapeStyle>: View {
        @Environment(\.displayScale) private var displayScale
        @State private var pixelCorrection: CGFloat = 0
        private let style: Style
        
        init(_ style: Style) {
            self.style = style
        }
        
        var body: some View {
            let scale = displayScale
            let thickness = 1 / scale
            Color.clear
                .frame(height: thickness)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(style)
                        .opacity(0.5)
                        .frame(height: thickness)
                        .offset(y: pixelCorrection)
                }
                .onGeometryChange(for: CGFloat.self) { proxy in
                    let minY = proxy.frame(in: .global).minY * scale
                    return (minY.rounded() - minY) / scale
                } action: { correction in
                    pixelCorrection = correction
                }
        }
    }
}
