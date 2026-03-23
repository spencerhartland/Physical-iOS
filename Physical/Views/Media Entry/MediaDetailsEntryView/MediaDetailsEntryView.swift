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
    
    // The media being edited
    private let media: Media?
    @Bindable private var draft: MediaDraft
    
    // View state
    @Binding var mediaAdded: Bool
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
        draft: Bindable<MediaDraft>,
        mediaAdded: Binding<Bool> = .constant(false),
        _ completion: @escaping () -> Void
    ) {
        self.media = nil
        self._draft = draft
        self._mediaAdded = mediaAdded
        self.completion = completion
        self.mediaColor = Color(draft.color.wrappedValue)
    }
    
    init(
        media: Media,
         _ completion: @escaping () -> Void
    ) {
        self.media = media
        self.draft = MediaDraft(from: media)
        self._mediaAdded = .constant(false)
        self.completion = completion
        self.mediaColor = Color(media.color)
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
        .croppedImagePicker(pickerIsPresented: $presentPhotosPicker, cameraIsPresented: $presentCamera, croppedImage: $newImage)
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
            Button("Done", systemImage: "checkmark") {
                uploadCachedImages()
                save()
                completion()
                withAnimation {
                    mediaAdded = true
                }
            }
        }
    }
    
    private var mediaImagesSection: some View {
        Section {
            // Official album art toggle
            Toggle(isOn: $draft.displaysOfficialArtwork) {
                ListItemLabel(
                    color: .blue,
                    symbolName: "checkmark.seal.fill",
                    labelText: "Display model"
                )
            }
            .alignmentGuide(.listRowSeparatorLeading) { dimensions in
                return dimensions[.leading]
            }
            
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
            MediaImageCarousel(
                for: draft.type,
                with: draft.albumArtworkURL,
                and: draft.color)
        }
    }
    
    private var physicalMediaDetailsSection: some View {
        Section {
            // Ownership
            OwnershipPicker(selection: $draft.isOwned)
            
            // Type
            Picker(selection: $draft.type) {
                ForEach(Media.MediaType.allCases) {
                    Text($0.rawValue)
                }
            } label: {
                ListItemLabel(color: .orange, symbol: mediaTypeSymbol, labelText: "Media type")
            }
            
            // Condition
            Picker(selection: $draft.condition) {
                ForEach(Media.MediaCondition.allCases) {
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
    
    
    private func save() {
        if let media {
            media.rawType = draft.rawType
            media.rawCondition = draft.rawCondition
            media.dateAdded = draft.dateAdded
            media.releaseDate = draft.releaseDate
            media.title = draft.title
            media.artist = draft.artist
            media.tracks = draft.tracks
            media.displaysOfficialArtwork = draft.displaysOfficialArtwork
            media.albumArtworkURL = draft.albumArtworkURL
            media.imageKeys = draft.imageKeys
            media.color = draft.color
            media.notes = draft.notes
            media.genre = draft.genre
            media.isFavorite = draft.isFavorite
            media.isOwned = draft.isOwned
        } else {
            let newMedia = Media(from: draft)
            modelContext.insert(newMedia)
        }
    }
    
    // MARK: - Image upload logic
    
    private func uploadCachedImages() {
        Task {
            do {
                try await ImageManager.shared.uploadFromCache(keys: draft.imageKeys)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
