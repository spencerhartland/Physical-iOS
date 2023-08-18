//
//  SocialProfileView.swift
//  Physical
//
//  Created by Spencer Hartland on 8/13/23.
//

import SwiftUI
import SwiftData

private enum ProfileViewSelection: String, Hashable, CaseIterable {
    case collection, posts
}

private enum ProfileSection: String {
    case favorites = "Favorites"
    case vinylRecords = "Vinyl Records"
    case compactDiscs = "Compact Discs"
    case compactCassettes = "Compact Cassettes"
    
    var predicate: Predicate<Media> {
        let vinylRecord = Media.MediaType.vinylRecord.rawValue
        let compactDisc = Media.MediaType.compactDisc.rawValue
        let compactCassette = Media.MediaType.compactCassette.rawValue
        
        switch self {
        case .favorites:
            return #Predicate { $0.isFavorite }
        case .vinylRecords:
            return #Predicate { $0.rawType == vinylRecord }
        case .compactDiscs:
            return #Predicate { $0.rawType == compactDisc }
        case .compactCassettes:
            return #Predicate { $0.rawType == compactCassette }
        }
    }
}

struct SocialProfileView: View {
    // Text constants
    private let segmentedControlTitle = "View collection or view posts"
    
    // SF Symbols
    private let followButtonSymbol = "plus.circle.fill"
    private let editProfileButtonSymbol = "pencil.circle.fill"
    private let profilePhotoPlaceholderSymbol = "camera"
    
    @State private var profileViewSelection: ProfileViewSelection = .collection
    @State private var screenSize: CGSize = {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        return window.screen.bounds.size
    }()
    
    @Query(
        filter: ProfileSection.favorites.predicate,
        sort: \.title
    )
    private var favoriteMedia: [Media]
    
    @Query(
        filter: ProfileSection.vinylRecords.predicate,
        sort: \.title
    )
    private var vinylRecords: [Media]
    
    @Query(
        filter: ProfileSection.compactDiscs.predicate,
        sort: \.title
    )
    private var compactDiscs: [Media]
    
    @Query(
        filter: ProfileSection.compactCassettes.predicate,
        sort: \.title
    )
    private var compactCassettes: [Media]
    
    var body: some View {
        let coverPhotoHeight = screenSize.height * 0.2
        let profilePhotoSize = screenSize.width * 0.2
        
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    coverPhoto(height: coverPhotoHeight)
                    profilePhoto(ofSize: profilePhotoSize)
                        .padding(.top, coverPhotoHeight - (profilePhotoSize / 2))
                }
                
                VStack(spacing: 0) {
                    // Display name
                    Text("Spencer")
                        .font(.title3.bold())
                        .padding(.top, 8)
                    // Username
                    Text("@spencer")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    // Biography
                    Text("imminent annihilation sounds so dope")
                        .font(.callout)
                        .padding(.top, 12)
                    
                    // Followers / following info
                    HStack {
                        HStack(spacing: 4) {
                            Text("10")
                            Text("Following")
                                .foregroundStyle(.secondary)
                        }
                        HStack(spacing: 4) {
                            Text("10,000")
                            Text("Followers")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .font(.callout)
                    .padding(.top, 8)
                    
                    // Collection / posts toggle
                    Picker(segmentedControlTitle, selection: $profileViewSelection) {
                        ForEach(ProfileViewSelection.allCases, id: \.self) { selection in
                            Text(selection.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.top, 24)
                }
                .padding(.horizontal)
                
                // Favorites section
                profileSectionView(
                    ProfileSection.favorites.rawValue,
                    content: favoriteMedia,
                    thumbnailWidth: screenSize.width - 24,
                    steppedScrolling: true
                )
                
                // Vinyl records
                profileSectionView(
                    ProfileSection.vinylRecords.rawValue,
                    content: vinylRecords,
                    thumbnailsOrnamented: false
                )
                
                // Compact discs
                profileSectionView(
                    ProfileSection.compactDiscs.rawValue,
                    content: compactDiscs,
                    thumbnailsOrnamented: false
                )
                
                // Compact cassettes
                profileSectionView(
                    ProfileSection.compactCassettes.rawValue,
                    content: compactCassettes,
                    thumbnailsOrnamented: false
                )
            }
            .padding(.bottom, 32)
        }
        .ignoresSafeArea()
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                //followButton
                // Show edit instead of follow on user's own profile
                editProfileButton
            }
        }
    }
    
    private var followButton: some View {
        Button {
            // do something...
        } label: {
            Image(systemName: followButtonSymbol)
                .resizable()
                .foregroundStyle(.thickMaterial)
        }
    }
    
    private var editProfileButton: some View {
        Button {
            // do something...
        } label: {
            Image(systemName: editProfileButtonSymbol)
                .resizable()
                .foregroundStyle(.thickMaterial)
        }
    }
    
    private func coverPhoto(height: CGFloat) -> some View {
        AsyncImage(url: URL(string: "https://fp-corporatewebsite-prod-umbraco.azurewebsites.net/api/media/getCroppedImage?imagePath=/media/l1thbnh0/1895-apple-park-01.jpg&width=2000&height=2000&crop=false")) { image in
            image
                .resizable()
        } placeholder: {
            Color(UIColor.secondarySystemBackground)
        }
        .frame(height: height)
    }
    
    private func profilePhoto(ofSize size: CGFloat) -> some View {
        ZStack {
            Circle()
                .foregroundStyle(Color(UIColor.systemBackground))
            AsyncImage(url: URL(string: "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ZStack {
                    Circle()
                        .foregroundStyle(.ultraThickMaterial)
                    Image(systemName: profilePhotoPlaceholderSymbol)
                        .foregroundStyle(.secondary)
                }
            }
            .clipShape(Circle())
            .padding(4)
        }
        .frame(width: size, height: size)
    }
    
    private func profileSectionView(
        _ title: String,
        content: [Media],
        thumbnailsOrnamented: Bool = true,
        thumbnailWidth: CGFloat? = nil,
        steppedScrolling: Bool = false
    ) -> some View {
        let mediaThumbnailWidth = thumbnailWidth ?? (screenSize.width / 2) - 24
        
        return VStack(alignment: .leading) {
            // Profile section title
            Text(title)
                .padding(.top, 24)
                .padding(.leading, 16)
                .font(.title2.weight(.semibold))
            
            // Media carousel
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: steppedScrolling ? 16 : 8) {
                    ForEach(0..<5) { index in
                        if index < content.count {
                            MediaThumbnail(for: content[index], ornamented: thumbnailsOrnamented)
                                .frame(width: mediaThumbnailWidth)
                                .padding(.top, 4)
                        }
                    }
                }
                .padding(.horizontal)
                .scrollTargetLayout()
            }
            .steppedScrollBehavior(steppedScrolling)
        }
    }
    
}

// View extension to optionally enable stepped scrolling for profile sections
fileprivate extension View {
    @ViewBuilder func steppedScrollBehavior(_ enabled: Bool) -> some View {
        if enabled {
            self
                .scrollTargetBehavior(.viewAligned)
        } else {
            self
        }
    }
}

#Preview {
    NavigationStack {
        SocialProfileView()
            .modelContainer(previewContainer)
    }
}
