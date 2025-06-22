//
//  MediaDetailsEntryView.swift
//  Vinyls
//
//  Created by Spencer Hartland on 7/9/23.
//

import SwiftUI
import PhotosUI

struct MediaDetailsEntryView: View {
    // Model context
    @Environment(\.modelContext) private var modelContext
    @Environment(\.screenSize) private var screenSize
    
    // The media being added to the collection
    @Bindable var newMedia: Media
    
    // View state
    @Binding var editingMediaDetails: Bool
    @State private var presentCamera = false
    @State private var presentPhotosPicker = false
    @FocusState private var focusInTrackField: Bool
    @State private var editMode = EditMode.inactive
    
    @State private var mediaTypeSymbol = Image(.vinylRecord)
    @State private var newImage: UIImage? = nil
    @State private var trackTitleText: String = ""
    @State private var mediaColor: Color
    
    init(newMedia: Bindable<Media>, isPresented: Binding<Bool>) {
        self._newMedia = newMedia
        self._editingMediaDetails = isPresented
        self.mediaColor = Color(newMedia.color.wrappedValue)
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.secondarySystemBackground)
                .ignoresSafeArea()
            
            List {
                mediaImagesSection
                physicalMediaDetailsSection
                ownershipPickerSection
                albumDetailsSection
                tracklistSection
                notesSection
            }
            .listRowBackground(Color(UIColor.systemBackground))
        }
        .navigationTitle("Details")
        .toolbar(.hidden, for: .tabBar)
        .environment(\.editMode, $editMode)
        .croppedImagePicker(pickerIsPresented: $presentPhotosPicker, cameraIsPresented: $presentCamera, croppedImage: $newImage)
        .onChange(of: newMedia.type) { _, newValue in
            // Change icon based upon the chosen physical media type
            switch newValue {
            case .vinylRecord:
                mediaTypeSymbol = Image(.vinylRecord)
            case .compactDisc:
                mediaTypeSymbol = Image(systemName: "opticaldisc.fill")
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
        .onChange(of: newImage) { _, image in
            // If the user captured / selected an image, save it
            do {
                if let image {
                    // Generate a key
                    let key = UUID().uuidString
                    // Cache the image
                    try ImageManager.shared.cache(image, withKey: key)
                    // Store the image key
                    newMedia.imageKeys.append(key)
                }
            } catch {
                print("There was an error caching the image.")
                print(error.localizedDescription)
            }
        }
        .toolbar {
            Button("Done") {
                uploadCachedImages()
                modelContext.insert(newMedia)
                editingMediaDetails = false
            }
        }
    }
    
    private var mediaImagesSection: some View {
        Section {
            // Official album art toggle
            Toggle(isOn: $newMedia.displaysOfficialArtwork) {
                ListItemLabel(
                    color: .blue,
                    symbolName: "checkmark.seal.fill",
                    labelText: "Display Official Artwork"
                )
            }
            
            // Add image menu
            Menu {
                // Take Photo
                Button {
                    presentCamera = true
                } label: {
                    Label("Take Photo", systemImage: "camera")
                }
                
                // Photo Library
                Button {
                    presentPhotosPicker = true
                } label: {
                    Label("Photo Library", systemImage: "photo.on.rectangle")
                }
            } label: {
                ListItemLabel(
                    color: .green,
                    symbolName: "plus.circle",
                    labelText: "Add image",
                    labelFontWeight: .semibold
                )
            }
        } header : {
            if !newMedia.imageKeys.isEmpty || (!newMedia.albumArtworkURL.isEmpty && newMedia.displaysOfficialArtwork) {
                MediaImageCarousel(
                    size: screenSize,
                    albumArtworkURL: newMedia.displaysOfficialArtwork ? newMedia.albumArtworkURL : nil,
                    mediaColor: newMedia.color,
                    imageKeys: newMedia.imageKeys,
                    mediaType: newMedia.type
                )
            }
        }
    }
    
    private var ownershipPickerSection: some View {
        Section {
            OwnershipPicker(selection: $newMedia.isOwned)
        }
    }
    
    private var physicalMediaDetailsSection: some View {
        Section {
            // Type
            Picker(selection: $newMedia.type) {
                ForEach(Media.MediaType.allCases) {
                    Text($0.rawValue)
                }
            } label: {
                ListItemLabel(color: .indigo, symbol: mediaTypeSymbol, labelText: "Media Type")
            }
            
            // Condition
            Picker(selection: $newMedia.condition) {
                ForEach(Media.MediaCondition.allCases) {
                    Text($0.rawValue)
                }
            } label: {
                ListItemLabel(color: .purple, symbolName: "sparkles", labelText: "Media Condition")
            }
            
            //Color
            if newMedia.type != .compactDisc {
                ColorPicker(selection: $mediaColor, supportsOpacity: true) {
                    ListItemLabel(color: .pink, symbolName: "paintpalette.fill", labelText: "Media color")
                }
                .onChange(of: mediaColor) { _, newColor in
                    newMedia.color = UIColor(newColor)
                }
            }
        } header: {
            Text("Physical media")
        }
    }
    
    private var albumDetailsSection: some View {
        Section {
            // Genre
            NavigationLink {
                GenreSelectionView(selection: $newMedia.genre)
            } label: {
                HStack {
                    ListItemLabel(color: .orange, symbolName: "guitars.fill", labelText: "Genre")
                    Spacer()
                    if !newMedia.genre.isEmpty {
                        Text(newMedia.genre)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            // Release date
            DatePicker(selection: $newMedia.releaseDate, displayedComponents: [.date]) {
                ListItemLabel(color: .red, symbolName: "calendar", labelText: "Release Date")
            }
            // Title
            TextField("Title", text: $newMedia.title)
            // Artist
            TextField("Artist", text: $newMedia.artist)
        } header: {
            Text("Album details")
        }
    }
    
    private var tracklistSection: some View {
        Tracklist($newMedia.tracks, editMode: $editMode, isEditable: true) {
            Text("Tracklist")
        }
    }
    
    private var notesSection: some View {
        NavigationLink {
            MediaNotesEntryView(notes: $newMedia.notes)
        } label: {
            ListItemLabel(color: .yellow, symbolName: "note.text", labelText: "Notes")
        }
    }
    
    // MARK: - Image upload logic
    
    private func uploadCachedImages() {
        Task {
            do {
                try await ImageManager.shared.uploadFromCache(keys: newMedia.imageKeys)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
