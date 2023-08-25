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

struct SocialProfileView: View {
    // Text constants
    private let segmentedControlTitle = "View collection or view posts"
    
    // SF Symbols
    private let followButtonSymbol = "plus.circle.fill"
    private let editProfileButtonSymbol = "pencil.circle.fill"
    private let profilePhotoPlaceholderSymbol = "camera"
    
    @State private var profileViewSelection: ProfileViewSelection = .collection
    
    @Namespace private var animationNamespace
    @Environment(\.screenSize) private var screenSize: CGSize
    
    var body: some View {
        let coverPhotoHeight = screenSize.height * 0.225
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
                    
                    // Featured section
                    FeaturedMediaView(title: "I Wanna Be Software", artist: "Grimes")
                    
                    // Collection / posts toggle
                    Picker(segmentedControlTitle, selection: $profileViewSelection) {
                        Text("Collection").tag(ProfileViewSelection.collection)
                        Text("Posts").tag(ProfileViewSelection.posts)
                    }
                    .pickerStyle(.segmented)
                    .padding(.top, 24)
                }
                .padding(.horizontal)
                
                if profileViewSelection == .collection {
                    SocialProfileCollectionView()
                } else {
                    SocialProfilePostsView()
                }
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
        }
    }
    
    private var editProfileButton: some View {
        Button {
            // do something...
        } label: {
            Image(systemName: editProfileButtonSymbol)
                .resizable()
        }
    }
    
    private func coverPhoto(height: CGFloat) -> some View {
        AsyncImage(url: URL(string: "https://fp-corporatewebsite-prod-umbraco.azurewebsites.net/api/media/getCroppedImage?imagePath=/media/l1thbnh0/1895-apple-park-01.jpg&width=2000&height=2000&crop=false")) { image in
            image
                .resizable()
                .overlay {
                    Rectangle()
                        .foregroundStyle(.ultraThinMaterial)
                        .mask {
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(0.85), location: 0.2),
                                    .init(color: .clear, location: 0.75)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                }
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
}

#Preview {
    @State var screenSize: CGSize = {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        return window.screen.bounds.size
    }()
    
    return NavigationStack {
        SocialProfileView()
            .modelContainer(previewContainer)
    }
    .environment(\.screenSize, screenSize)
}
