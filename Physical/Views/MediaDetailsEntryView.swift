//
//  MediaDetailsEntryView.swift
//  Vinyls
//
//  Created by Spencer Hartland on 7/9/23.
//

import SwiftUI
import PhotosUI

fileprivate enum EntryState {
    case reviewingDetails, takingPhoto, selectingPhotos
}

struct MediaDetailsEntryView: View {
    private let navTitle = "Review Details"
    private let albumInfoSectionHeaderText = "Album info"
    private let mediaInfoSectionHeaderText = "Physical media"
    private let albumTitleText = "Title"
    private let albumArtistText = "Artist"
    private let albumReleaseDateText = "Release Date"
    private let mediaTypeText = "Media Type"
    private let mediaConditionText = "Media Condition"
    
    @Binding var newMedia: Media
    
    // View state
    @State private var state: EntryState = .reviewingDetails
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
                        self.state = .takingPhoto
                    } label: {
                        Label("Take Photo", systemImage: "camera")
                    }
                    
                    Button {
                        self.state = .selectingPhotos
                    } label: {
                        Label("Photo Library", systemImage: "photo.on.rectangle")
                    }
                } label: {
                    ListItemLabel(color: .green, symbolName: "photo.fill", labelText: "Add image")
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
                        ListItemLabel(color: .purple, symbolName: "sparkles", labelText: mediaConditionText)
                    }
                } header: {
                    Text(mediaInfoSectionHeaderText)
                }
                
                // Album Info
                Section {
                    // Release date
                    DatePicker(selection: $newMedia.releaseDate, displayedComponents: [.date]) {
                        ListItemLabel(color: .red, symbolName: "calendar", labelText: albumReleaseDateText)
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
                mediaTypeSymbol = Image(systemName: "opticaldisc.fill")
            case .compactCassette:
                mediaTypeSymbol = Image(.compactCassette)
            }
        }
        .onChange(of: state) { _, newValue in
            switch newValue {
            case .takingPhoto:
                presentCamera = true
                break
            case .selectingPhotos:
                presentPhotosPicker = true
                break
            default:
                break
            }
        }
        .onChange(of: presentCamera) { _, newValue in
            if newValue == false {
                self.state = .reviewingDetails
            }
        }
        .onChange(of: presentPhotosPicker) { _, newValue in
            if newValue == false {
                self.state = .reviewingDetails
            }
        }
    }
}
