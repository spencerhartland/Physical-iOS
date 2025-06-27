//
//  RootView.swift
//  Physical
//
//  Created by Spencer Hartland on 8/24/23.
//

import SwiftUI
import SwiftData

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
    @State private var shouldShowMediaAddedToast: Bool = false
    
    @Query private var media: [Media]
    
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
            if !userID.isEmpty {
                signInSheetPresented = false
            }
        }
        // Modifiers for "Added to Collection" notification
        .onChange(of: media) { oldValue, newValue in
            if oldValue.count < newValue.count {
                shouldShowMediaAddedToast = true
            }
        }
        .overlay(alignment: .bottom) {
            if shouldShowMediaAddedToast { mediaAddedToast }
        }
        .sensoryFeedback(trigger: shouldShowMediaAddedToast) {
            shouldShowMediaAddedToast ? .success : nil
        }
    }
    
    private var mediaAddedToast: some View {
        Label("Added to Collection", systemImage: "checkmark.circle.fill")
            .fontWeight(.medium)
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .background { Capsule().fill(Color(UIColor.tertiarySystemBackground)) }
            .padding(.bottom, screenSize.height / 6)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    withAnimation { shouldShowMediaAddedToast = false }
                }
            }
            .transition(.opacity)
    }
}

#Preview {
    RootView()
        .modelContainer(previewContainer)
}
