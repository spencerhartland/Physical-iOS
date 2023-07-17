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
    private let tracksSectionHeaderText = "Tracks"
    private let addTrackText = "Track title"
    private let tracklistEditButtonText = "Edit tracklist"
    private let tracklistCancelButtonText = "Cancel"
    
    // SF Symbol names
    private let takePhotoMenuItemSymbol = "camera"
    private let photoLibarayMenuItemSymbol = "photo.on.rectangle"
    private let addImageSymbol = "photo.fill"
    private let mediaConditionSymbol = "sparkles"
    private let albumReleaseDateSymbol = "calendar"
    private let compactDiscSymbol = "opticaldisc.fill"
    private let addTrackSymbol = "plus.circle.fill"
    private let beginEditingSymbol = "pencil"
    private let stopEditingSymbol = "pencil.slash"
    
    // The media being added to the collection
    @Binding var newMedia: Media
    
    // View state
    @State private var presentCamera = false
    @State private var presentPhotosPicker = false
    @FocusState private var focusInTrackField: Bool
    @State private var editMode = EditMode.inactive
    
    @State private var mediaTypeSymbol = Image(.vinylRecord)
    @State private var chosenImage: PhotosPickerItem? = nil
    @State private var capturedImage: UIImage? = nil
    @State private var trackTitleText: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                // Add image
                Menu {
                    // Take Photo
                    Button {
                        presentCamera = true
                    } label: {
                        Label(takePhotoMenuItemText, systemImage: takePhotoMenuItemSymbol)
                    }
                    
                    // Photo Library
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
                
                // Tracks
                Section {
                    if !newMedia.tracks.isEmpty {
                        ForEach(Array(newMedia.tracks.enumerated()), id: \.element) { trackNum, trackTitle in
                            HStack {
                                Text("\(trackNum + 1)")
                                    .foregroundStyle(.secondary)
                                    .font(.headline)
                                Text(trackTitle)
                                    .lineLimit(1)
                            }
                        }
                        .onDelete(perform: removeTrack)
                        .onMove(perform: moveTrack)
                    }
                    
                    TextField(addTrackText, text: $trackTitleText)
                        .focused($focusInTrackField)
                } header: {
                    Text(tracksSectionHeaderText)
                } footer: {
                    HStack {
                        Spacer()
                        tracklistEditButton
                        Spacer()
                    }
                }
            }
        }
        .photosPicker(isPresented: $presentPhotosPicker, selection: $chosenImage, matching: .images)
        .fullScreenCover(isPresented: $presentCamera) {
            ImagePicker(image: $capturedImage)
                .ignoresSafeArea()
        }
        .navigationTitle(navTitle)
        .environment(\.editMode, $editMode)
        .background {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
        }
        .onChange(of: newMedia.type) { _, newValue in
            // Change icon based upon the chosen physical media type
            switch newValue {
            case .vinylRecord:
                mediaTypeSymbol = Image(.vinylRecord)
            case .compactDisc:
                mediaTypeSymbol = Image(systemName: compactDiscSymbol)
            case .compactCassette:
                mediaTypeSymbol = Image(.compactCassette)
            }
        }
        .onChange(of: focusInTrackField) { _, focused in
            if !focused && !trackTitleText.isEmpty {
                newMedia.tracks.append(trackTitleText)
                trackTitleText = ""
            }
        }
    }
    
    private var tracklistEditButton: some View {
        HStack {
            Spacer()
            Button {
                editMode = editMode == .active ? EditMode.inactive : EditMode.active
            } label: {
                HStack {
                    Image(systemName: editMode == .active ? stopEditingSymbol : beginEditingSymbol)
                    if editMode == .active {
                        Text(tracklistCancelButtonText)
                    } else {
                        Text(tracklistEditButtonText)
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .buttonStyle(.bordered)
            .disabled($newMedia.tracks.isEmpty)
            Spacer()
        }
    }
    
    // MARK: - Track list editing logic
    
    private func removeTrack(at offsets: IndexSet) {
        newMedia.tracks.remove(atOffsets: offsets)
        endEditingIfTracklistEmpty()
    }
    
    private func moveTrack(source: IndexSet, destination: Int) {
        newMedia.tracks.move(fromOffsets: source, toOffset: destination)
    }
    
    private func endEditingIfTracklistEmpty() {
        if newMedia.tracks.isEmpty && editMode == .active {
            editMode = .inactive
        }
    }
}
