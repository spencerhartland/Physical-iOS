//
//  RootView.swift
//  Physical
//
//  Created by Spencer Hartland on 8/24/23.
//

import SwiftUI

struct RootView: View {
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
                    Label("Collection", systemImage: "square.stack.fill")
                }
                .tag(0)
            
            SocialView(for: $userID)
                .tabItem {
                    Label("Social", systemImage: "at.circle.fill")
                }
                .sheet(isPresented: $signInSheetPresented) {
                    OnboardingSheet($signInSheetPresented)
                }
                .tag(1)
            
            SocialProfileView(for: $userID)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .sheet(isPresented: $signInSheetPresented) {
                    OnboardingSheet($signInSheetPresented)
                }
                .tag(2)
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
