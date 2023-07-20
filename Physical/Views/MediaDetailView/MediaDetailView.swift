//
//  MediaDetailView.swift
//  Physical
//
//  Created by Spencer Hartland on 7/19/23.
//

import SwiftUI

struct MediaDetailView: View {
    private let favoriteMenuItemText = "Favorite"
    private let editMenuItemText = "Edit details"
    private let shareMenuItemText = "Share"
    private let deleteMenuItemText = "Delete from Collection"
    private let releaseDateText = "Released on"
    private let dateAddedText = "Aquired on"
    
    private let moreMenuSymbol = "ellipsis.circle.fill"
    private let notFavoriteMenuItemSymbol = "heart"
    private let favoriteMenuItemSymbol = "heart.fill"
    private let editMenuItemSymbol = "square.and.pencil"
    private let shareMenuItemSymbol = "square.and.arrow.up"
    private let deleteMenuItemSymbol = "trash"
    private let compactDiscSymbol = "opticaldisc.fill"
    private let horizontalDetailsSeparatorSymbol = "circle.fill"
    
    var media: Media
    @State private var screenSize: CGSize = {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        return window.screen.bounds.size
    }()
    
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
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                moreMenu
            }
        }
    }
    
    private var moreMenu: some View {
        Menu {
            Button {
                // media.isFavorite.toggle()
            } label: {
                Label(favoriteMenuItemText, systemImage: notFavoriteMenuItemSymbol)
            }
            Divider()
            Button {
                // Navigate to MediaDetailsEntryView
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
                // Delete media
            } label: {
                Label(deleteMenuItemText, systemImage: deleteMenuItemSymbol)
            }
        } label: {
            Image(systemName: moreMenuSymbol)
        }
    }
    
    private var albumArtWithDetails: some View {
        VStack {
            MediaImageCarousel(size: screenSize, imageURLStrings: media.images)
            VStack {
                // Title
                Text(media.title)
                    .font(.title.weight(.semibold))
                    .foregroundStyle(.primary)
                // Artist
                Text(media.artist)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 16)
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
                Text("Genre")
            }
            .font(.system(.caption, weight: .medium))
            .foregroundStyle(.secondary)
            .padding(.bottom, 32)
        }
        .textCase(.none)
        .foregroundStyle(.primary)
    }
    
    private var tracklistFooter: some View {
        VStack(alignment: .leading) {
            Text("\(releaseDateText) \(media.releaseDate, format: .dateTime.month().day().year())")
            Text("\(dateAddedText) \(media.dateAdded, format: .dateTime.month().day().year())")
        }
    }
    
    private var tracklist: some View {
        ForEach(Array(media.tracks.enumerated()), id: \.element) { trackNum, trackTitle in
            HStack {
                Text("\(trackNum + 1)")
                    .foregroundStyle(.secondary)
                    .font(.headline)
                Text(trackTitle)
                    .lineLimit(1)
            }
        }
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
