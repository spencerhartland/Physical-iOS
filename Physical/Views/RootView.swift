//
//  RootView.swift
//  Physical
//
//  Created by Spencer Hartland on 8/24/23.
//

import SwiftUI

struct RootView: View {
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
                    Label("Collection", systemImage: "square.stack.fill")
                }
            Text("Coming soon")
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            SocialProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .environment(\.screenSize, screenSize)
    }
}

#Preview {
    RootView()
        .modelContainer(previewContainer)
}
