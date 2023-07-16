//
//  MediaDetailsEntryView.swift
//  Vinyls
//
//  Created by Spencer Hartland on 7/9/23.
//

import SwiftUI
import PhotosUI

struct MediaDetailsEntryView: View {
    // String constants
    private let navTitle = "Review Details"
    private let albumInfoSectionHeaderText = "Album info"
    private let mediaInfoSectionHeaderText = "Physical media"
    private let albumTitleText = "Title"
    private let albumArtistText = "Artist"
    private let albumReleaseDateText = "Release Date"
    private let mediaTypeText = "Media Type"
    private let mediaConditionText = "Media Condition"
    private let takePhotoMenuItemText = "Take Photo"
    private let photoLibarayMenuItemText = "Photo Library"
    private let addImageText = "Add image"
    
    // SF Symbol names
    private let takePhotoMenuItemSymbol = "camera"
    private let photoLibarayMenuItemSymbol = "photo.on.rectangle"
    private let addImageSymbol = "photo.fill"
    private let mediaConditionSymbol = "sparkles"
    private let albumReleaseDateSymbol = "calendar"
    private let compactDiscSymbol = "opticaldisc.fill"
    
    // The media being added to the collection
    @Binding var newMedia: Media
    
    // View state
    @State private var presentCamera = false
    @State private var presentPhotosPicker = false
    
    @State private var mediaTypeSymbol = Image(.vinylRecord)
    @State private var chosenImages: PhotosPickerItem? = nil
    @State private var chosenImage: UIImage? = nil
    
    var body: some View {
        NavigationStack {
            List {
                Menu {
                    Button {
                        presentCamera = true
                    } label: {
                        Label(takePhotoMenuItemText, systemImage: takePhotoMenuItemSymbol)
                    }
                    
                    Button {
                        presentPhotosPicker = true
                    } label: {
                        Label(photoLibarayMenuItemText, systemImage: photoLibarayMenuItemSymbol)
                    }
                } label: {
                    ListItemLabel(color: .green, symbolName: addImageSymbol, labelText: addImageText)
                        .font(.headline)
                }
                
                // Physical Media
                Section {
                    // Type
                    Picker(selection: $newMedia.type) {
                        ForEach(Media.MediaType.allCases) {
                            Text($0.rawValue)
                        }
                    } label: {
                        ListItemLabel(color: .blue, symbol: mediaTypeSymbol, labelText: mediaTypeText)
                    }
                    // Condition
                    Picker(selection: $newMedia.condition) {
                        ForEach(Media.MediaCondition.allCases) {
                            Text($0.rawValue)
                        }
                    } label: {
                        ListItemLabel(color: .purple, symbolName: mediaConditionSymbol, labelText: mediaConditionText)
                    }
                } header: {
                    Text(mediaInfoSectionHeaderText)
                }
                
                // Album Info
                Section {
                    // Release date
                    DatePicker(selection: $newMedia.releaseDate, displayedComponents: [.date]) {
                        ListItemLabel(color: .red, symbolName: albumReleaseDateSymbol, labelText: albumReleaseDateText)
                    }
                    // Title
                    TextField(albumTitleText, text: $newMedia.title)
                    // Artist
                    TextField(albumArtistText, text: $newMedia.artist)
                } header: {
                    Text(albumInfoSectionHeaderText)
                }
            }
        }
        .photosPicker(isPresented: $presentPhotosPicker, selection: $chosenImages, matching: .images)
        .fullScreenCover(isPresented: $presentCamera) {
            ImagePicker(image: $chosenImage)
                .ignoresSafeArea()
        }
        .navigationTitle(navTitle)
        .background {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
        }
        .onChange(of: newMedia.type) { _, newValue in
            switch newValue {
            case .vinylRecord:
                mediaTypeSymbol = Image(.vinylRecord)
            case .compactDisc:
                mediaTypeSymbol = Image(systemName: compactDiscSymbol)
            case .compactCassette:
                mediaTypeSymbol = Image(.compactCassette)
            }
        }
    }
}
