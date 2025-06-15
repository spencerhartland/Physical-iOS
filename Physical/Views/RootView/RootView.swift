//
//  RootView.swift
//  Physical
//
//  Created by Spencer Hartland on 8/24/23.
//

import SwiftUI

struct RootView: View {
    private let collectionTabItemText = "Collection"
    private let addMediaTabItemText = "Add to Collection"
    private let socialTabItemText = "Social"
    private let profileTabItemText = "Profile"
    
    private let collectionTabItemSymbol = "square.stack.fill"
    private let addMediaTabItemSymbol = "square.badge.plus.fill"
    private let socialTabItemSymbol = "at"
    private let profileTabItemSymbol = "person.crop.circle.fill"
    
    @AppStorage(StorageKeys.userID) private var userID: String = ""
    @State private var signInSheetPresented: Bool = true
    @State private var screenSize: CGSize = {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        return window.screen.bounds.size
    }()
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MediaCollectionView($selectedTab)
                .tabItem {
                    Label(collectionTabItemText, systemImage: collectionTabItemSymbol)
                }
                .tag(0)
            
            AddMediaView($selectedTab)
                .tabItem {
                    Label(addMediaTabItemText, systemImage: addMediaTabItemSymbol)
                }
                .tag(1)
            
            SocialView(for: $userID)
                .tabItem {
                    Label(socialTabItemText, systemImage: socialTabItemSymbol)
                }
                .sheet(isPresented: $signInSheetPresented) {
                    OnboardingSheet($signInSheetPresented)
                }
                .tag(2)
            
            SocialProfileView(for: $userID)
                .tabItem {
                    Label(profileTabItemText, systemImage: profileTabItemSymbol)
                }
                .sheet(isPresented: $signInSheetPresented) {
                    OnboardingSheet($signInSheetPresented)
                }
                .tag(3)
        }
        .environment(\.screenSize, screenSize)
        .onAppear {
            // If there is a user ID in UserDefaults, do not ask to sign in.
            if !userID.isEmpty {
                signInSheetPresented = false
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(previewContainer)
}
