//
//  SocialSimplePostView.swift
//  Physical
//
//  Created by Spencer Hartland on 8/26/23.
//

import SwiftUI

// A simple post consists of user-generated text and a single media item
// (song, album, or playlist)
struct SocialSimplePostView: View {
    @Environment(\.screenSize) private var screenSize
    
    var body: some View {
        let profilePhotoSize = screenSize.width * 0.08
        
        Grid(horizontalSpacing: 8, verticalSpacing: 8) {
            GridRow(alignment: .center) {
                Circle()
                    .frame(width: profilePhotoSize, height: profilePhotoSize)
                userInfo(displayName: "Spencer", userName: "@spencer")
            }
            GridRow(alignment: .top) {
                Spacer()
                VStack(alignment: .leading, spacing: 16) {
                    Text("This is a simple post!")
                    CompactMediaView(title: "I Wanna Be Software", artist: "Grimes")
                    SocialPostBottomBar()
                }
            }
        }
        .frame(width: screenSize.width - 32)
    }
    
    private func userInfo(displayName: String, userName: String) -> some View {
        HStack {
            Text(displayName)
                .font(.headline)
            Text(userName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}

#Preview {
    @State var screenSize: CGSize = {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        return window.screen.bounds.size
    }()
    
    return List {
        SocialSimplePostView()
        SocialSimplePostView()
        SocialSimplePostView()
    }
    .environment(\.screenSize, screenSize)
    .listStyle(.plain)
}
