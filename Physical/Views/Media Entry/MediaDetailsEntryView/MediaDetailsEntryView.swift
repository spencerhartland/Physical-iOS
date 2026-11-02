//
//  MediaDetailsEntryView.swift
//  Vinyls
//
//  Created by Spencer Hartland on 7/9/23.
//

import PhotosUI
import PhysicalMediaKit
import SwiftData
import SwiftUI

struct MediaDetailsEntryView: View {
    // Model context
    @Environment(\.modelContext) private var modelContext
    
    // The media being edited
    @Binding private var draft: MediaDraft
    
    // View state
    @State private var presentCamera = false
    @State private var presentPhotosPicker = false
    @FocusState private var focusInTrackField: Bool
    @State private var editMode = EditMode.inactive
    
    @State private var mediaTypeSymbol = Image(.vinylRecord)
    @State private var newImage: UIImage? = nil
    @State private var trackTitleText: String = ""
    @State private var mediaColor: Color
    
    private var completion: () -> Void
    
    init(
        draft: Binding<MediaDraft>,
        _ completion: @escaping () -> Void
    ) {
        self._draft = draft
        self.completion = completion
        self.mediaColor = Color(draft.color.wrappedValue)
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.secondarySystemBackground)
                .ignoresSafeArea()
            
            List {
                mediaImagesSection
                physicalMediaDetailsSection
                notesSection
                albumDetailsSection
                tracklistSection
            }
            .listRowBackground(Color(UIColor.systemBackground))
        }
        .navigationTitle("Details")
        .toolbar(.hidden, for: .tabBar)
        .environment(\.editMode, $editMode)
        .croppedImagePicker(
            pickerIsPresented: $presentPhotosPicker,
            cameraIsPresented: $presentCamera,
            croppedImage: $newImage
        )
        .onChange(of: draft.type) { _, newValue in
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
                draft.tracks.append(trackTitleText)
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
                    draft.imageKeys.append(key)
                }
            } catch {
                print("There was an error caching the image.")
                print(error.localizedDescription)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Done", systemImage: "checkmark") { completion() }
                    .prominentButtonStyle()
                    .tint(.physicalGreen)
            }
        }
    }
    
    private var mediaImagesSection: some View {
        Section {
            // Official album art toggle
            Toggle(isOn: $draft.displaysOfficialArtwork) {
                ListItemLabel(
                    color: .blue,
                    symbolName: draft.displaysOfficialArtwork ? "eye.fill" : "eye.slash.fill",
                    labelText: "Display model"
                )
            }
            .alignmentGuide(.listRowSeparatorLeading) { dimensions in
                return dimensions[.leading]
            }
            .disabled(draft.imageKeys.isEmpty)
            
            // Add image menu
            Menu("Add photo") {
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
            }
            .foregroundStyle(.blue)
        } header : {
            MediaImageCarousel(for: draft) { keyToRemove in
                // Remove key from media
                draft.imageKeys.removeAll { key in
                    return key == keyToRemove
                }
                // Remove key / image from cache
                do {
                    try ImageManager.shared.removeImage(withKey: keyToRemove)
                } catch {
                    Log.general.error("Unable to remove image: \(error.localizedDescription).")
                }
                // Enforce no placeholder
                if draft.imageKeys.isEmpty {
                    withAnimation { draft.displaysOfficialArtwork = true }
                }
            }
        }
    }
    
    private var physicalMediaDetailsSection: some View {
        Section {
            // Ownership
            OwnershipPicker(selection: $draft.isOwned)
            
            // Type
            Picker(selection: $draft.type) {
                ForEach(MediaType.allCases) {
                    Text($0.rawValue)
                }
            } label: {
                ListItemLabel(color: .orange, symbol: mediaTypeSymbol, labelText: "Media type")
            }
            
            // Condition
            Picker(selection: $draft.condition) {
                ForEach(Media.Condition.allCases) {
                    Text($0.rawValue)
                }
            } label: {
                ListItemLabel(color: .purple, symbolName: "sparkles", labelText: "Media condition")
            }
            
            //Color
            if draft.type != .compactDisc {
                ColorPicker(selection: $mediaColor, supportsOpacity: true) {
                    ListItemLabel(color: .indigo, symbolName: "paintpalette.fill", labelText: "Media color")
                }
                .onChange(of: mediaColor) { _, newColor in
                    draft.color = UIColor(newColor)
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
                GenreSelectionView(selection: $draft.genre)
            } label: {
                HStack {
                    ListItemLabel(color: .orange, symbolName: "guitars.fill", labelText: "Genre")
                    Spacer()
                    if !draft.genre.isEmpty {
                        Text(draft.genre)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            // Release date
            DatePicker(selection: $draft.releaseDate, displayedComponents: [.date]) {
                ListItemLabel(color: .red, symbolName: "calendar", labelText: "Release date")
            }
            .alignmentGuide(.listRowSeparatorLeading) { dimensions in
                return dimensions[.leading]
            }
            // Title
            TextField("Title", text: $draft.title)
                .alignmentGuide(.listRowSeparatorLeading) { dimensions in
                    return dimensions[.leading]
                }
            // Artist
            TextField("Artist", text: $draft.artist)
        } header: {
            Text("Album details")
        }
    }
    
    private var tracklistSection: some View {
        Tracklist($draft.tracks, editMode: $editMode, isEditable: true) {
            Text("Tracklist")
        }
    }
    
    private var notesSection: some View {
        NavigationLink {
            MediaNotesEntryView(notes: $draft.notes)
        } label: {
            ListItemLabel(color: .yellow, symbolName: "note.text", labelText: "Notes")
        }
    }
}
