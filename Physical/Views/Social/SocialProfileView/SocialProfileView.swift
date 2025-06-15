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
    private let followingCountText = "following"
    private let followerCountText = "follower"
    private let segmentedControlTitle = "View collection or view posts"
    private let fetchingInProgressTitleText = "Please wait"
    private let fetchingInProgressDescriptionText = "Fetching profile..."
    private let segmentedControlCollectionTitle = "Collection"
    private let segmentedControlPostsTitle = "Posts"
    
    // SF Symbols
    private let followButtonSymbol = "plus.circle.fill"
    private let editProfileButtonSymbol = "gear"
    private let profilePhotoPlaceholderSymbol = "person.crop.circle.dashed"
    private let fetchingInProgressSymbol = "person.crop.circle.fill"
    
    @Binding var userID: String
    
    @State private var user: User? = nil
    @State private var profileViewSelection: ProfileViewSelection = .collection
    @State private var editingProfile: Bool = false
    
    @Environment(\.screenSize) private var screenSize: CGSize
    
    init(for userID: Binding<String>) {
        self._userID = userID
    }
    
    var body: some View {
        NavigationStack {
            if userID.isEmpty {
                NoAccountView()
            } else if let user {
                profileView(for: user)
                    .navigationDestination(isPresented: $editingProfile) {
                        SocialProfileSettingsView(user: user)
                    }
            } else {
                fetchingInProgressView
            }
        }
        .onAppear {
            if !userID.isEmpty {
                fetchSocialProfile()
            }
        }
    }
    
    // MARK: - Profile view
    
    private func profileView(for user: User) -> some View {
        let coverPhotoHeight = screenSize.height * 0.225
        let profilePhotoSize = screenSize.width * 0.2
        
        return ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    coverPhoto(user.coverPhotoURL, height: coverPhotoHeight)
                    profilePhoto(user.profilePhotoURL, ofSize: profilePhotoSize)
                        .padding(.top, coverPhotoHeight - (profilePhotoSize / 2))
                }
                
                VStack(spacing: 0) {
                    // Display name
                    Text(user.displayName)
                        .font(.title3.bold())
                        .padding(.top, 8)
                    // Username
                    Text("@\(user.username)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    // Biography
                    Text(user.biography)
                        .font(.callout)
                        .padding(.top, 12)
                    
                    // Followers / following info
                    HStack {
                        HStack(spacing: 4) {
                            Text("\(user.following.count)")
                            Text(followingCountText)
                                .foregroundStyle(.secondary)
                        }
                        HStack(spacing: 4) {
                            Text("\(user.followers.count)")
                            Text(followerCountText + (user.followers.count == 1 ? "" : "s"))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .font(.callout)
                    .padding(.top, 8)
                    
                    // Featured section
                    FeaturedMediaView(title: "I Wanna Be Software", artist: "Grimes")
                        .padding(.top, 24)
                    
                    // Collection / posts toggle
                    Picker(segmentedControlTitle, selection: $profileViewSelection) {
                        Text(segmentedControlCollectionTitle).tag(ProfileViewSelection.collection)
                        Text(segmentedControlPostsTitle).tag(ProfileViewSelection.posts)
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
        .ignoresSafeArea(edges: [.top, . horizontal])
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
            editingProfile.toggle()
        } label: {
            Image(systemName: editProfileButtonSymbol)
                .resizable()
        }
    }
    
    private func coverPhoto(_ urlString: String, height: CGFloat) -> some View {
        AsyncImage(url: URL(string: urlString)) { image in
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
    
    private func profilePhoto(_ urlString: String, ofSize size: CGFloat) -> some View {
        ZStack {
            Circle()
                .foregroundStyle(Color(UIColor.systemBackground))
            AsyncImage(url: URL(string: urlString)) { image in
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
    
    // MARK: - Fetching in progress view
    private var fetchingInProgressView: some View {
        ContentUnavailableView(fetchingInProgressTitleText, systemImage: fetchingInProgressSymbol, description: Text(fetchingInProgressDescriptionText))
            .symbolEffect(.pulse.wholeSymbol)
    }
    
    // MARK: - User fetch logic
    // Fetches the social profile associated with the current userID and triggers a UI update.
    private func fetchSocialProfile() {
        Task {
            do {
                let fetchedUser = try await UserAccountManager.shared.fetchAccount(with: self.userID)
                updateProfile(with: fetchedUser)
            } catch {
                print(error)
            }
        }
    }
    
    // Updates the user property on the main thread.
    @MainActor
    private func updateProfile(with user: User) {
        self.user = user
    }
}
