//
//  RootView.swift
//  Physical
//
//  Created by Spencer Hartland on 8/24/23.
//

import SwiftUI

struct RootView: View {
    private let collectionTabItemText = "Collection"
    private let socialTabItemText = "Social"
    private let profileTabItemText = "Profile"
    
    private let collectionTabItemSymbol = "square.stack.fill"
    private let socialTabItemSymbol = "at.circle.fill"
    private let profileTabItemSymbol = "person.crop.circle.fill"
    
    @AppStorage(StorageKeys.userID) private var userID: String = ""
    @State private var shouldRequestSignIn: Bool = true
    @State private var screenSize: CGSize = {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        return window.screen.bounds.size
    }()
    
    var body: some View {
        TabView {
            MediaCollectionView()
                .tabItem {
                    Label(collectionTabItemText, systemImage: collectionTabItemSymbol)
                }
            SocialView(for: $userID)
                .tabItem {
                    Label(socialTabItemText, systemImage: socialTabItemSymbol)
                }
                .sheet(isPresented: $shouldRequestSignIn) {
                    OnboardingSheet($shouldRequestSignIn)
                }
            SocialProfileView(for: $userID)
                .tabItem {
                    Label(profileTabItemText, systemImage: profileTabItemSymbol)
                }
                .sheet(isPresented: $shouldRequestSignIn) {
                    OnboardingSheet($shouldRequestSignIn)
                }
        }
        .environment(\.screenSize, screenSize)
        .onAppear {
            // If there is a user ID in UserDefaults, do not ask to sign in.
            if !userID.isEmpty {
                shouldRequestSignIn = false
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(previewContainer)
}
