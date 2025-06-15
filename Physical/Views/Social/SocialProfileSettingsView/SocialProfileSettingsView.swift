//
//  SocialProfileSettingsView.swift
//  Physical
//
//  Created by Spencer Hartland on 1/11/24.
//

import SwiftUI
import SwiftData

struct SocialProfileSettingsView: View {
    // Text
    private let navigationTitle = "Settings"
    private let photosSectionTitle = "Photos"
    private let detailsSectionTitle = "Details"
    private let biographySectionTitle = "About"
    private let displayNameTitleText = "Display name"
    private let displayNameTextfieldPromptText = "Enter your name"
    private let coverPhotoText = "Choose a cover photo"
    private let profilePhotoText = "Choose a profile photo"
    private let usernameTitleText = "Username"
    private let usernameTextfieldPromptText = "username"
    private let biographyPromptText = "Write something..."
    // SF Symbol names
    private let coverPhotoSymbolName = "photo.fill"
    private let profilePhotoSymbolName = "person.crop.circle.dashed"
    private let usernameSymbolName = "at"
    private let biographySymbolName = "character.cursor.ibeam"
    private let disclosureIndicatorSymbolName = "chevron.right"
    
    @Bindable var user: User
    
    @Environment(\.screenSize) private var screenSize: CGSize
    
    var body: some View {
        NavigationStack {
            List {
                Section(photosSectionTitle) {
                    HStack(spacing: 32) {
                        profilePhotoEditButton
                        coverPhotoEditButton
                    }
                    .frame(height: screenSize.height / 8)
                }
                .listRowBackground(EmptyView())
                
                Section(detailsSectionTitle) {
                    displayNameTextfield
                    usernameTextfield
                }
                
                Section(biographySectionTitle) {
                    biographyTextfield
                }
            }
            .headerProminence(.increased)
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var coverPhotoEditButton: some View {
        VStack(alignment: .leading) {
            Button {
                // Do something...
            } label: {
                if user.coverPhotoURL.isEmpty {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundStyle(Color(uiColor: .systemFill))
                        Image(systemName: coverPhotoSymbolName)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    // Display cover photo
                }
            }
            Text("Cover Photo")
                .font(.caption)
        }
    }
    
    private var profilePhotoEditButton: some View {
        VStack(alignment: .center) {
            Button {
                // Do something...
            } label: {
                if user.profilePhotoURL.isEmpty {
                    ZStack {
                        Circle()
                            .foregroundStyle(Color(uiColor: .systemFill))
                        Image(systemName: profilePhotoSymbolName)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    // Display cover photo
                }
            }
            Text("Profile Photo")
                .font(.caption)
        }
    }
    
    private var displayNameTextfield: some View {
        HStack {
            Text(displayNameTitleText)
            TextField(displayNameTextfieldPromptText, text: $user.displayName)
                .multilineTextAlignment(.trailing)
        }
    }
    
    private var usernameTextfield: some View {
        HStack {
            Text(usernameTitleText)
            Spacer()
            HStack(spacing: 2) {
                Text("@")
                TextField(user.username.isEmpty ? usernameTextfieldPromptText : "", text: $user.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .lineLimit(1)
                    .fixedSize()
            }
        }
    }
    
    private var biographyTextfield: some View {
        ZStack {
            if user.biography.isEmpty {
                VStack {
                    HStack {
                        Text(biographyPromptText)
                        Spacer()
                    }
                    Spacer()
                }
                .foregroundStyle(.tertiary)
                .padding(.top, 8)
                .padding(.leading, 4)
            }
            TextEditor(text: $user.biography)
        }
    }
}

#Preview {
    @Previewable @State var screenSize: CGSize = {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        return window.screen.bounds.size
    }()
    
    let previewConfig = ModelConfiguration(isStoredInMemoryOnly: true)
    let previewContainer = try! ModelContainer(for: User.self, configurations: previewConfig)
    
    let previewUser = User(with: "", username: "", collection: "")
    return NavigationStack {
        Color.white
            .navigationDestination(isPresented: .constant(true)) {
                SocialProfileSettingsView(user: previewUser)
                    .environment(\.screenSize, screenSize)
            }
            .modelContainer(previewContainer)
    }
}
