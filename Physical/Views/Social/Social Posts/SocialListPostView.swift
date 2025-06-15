//
//  SocialListPostView.swift
//  Physical
//
//  Created by Spencer Hartland on 8/29/23.
//

import SwiftUI

struct SocialListPostView: View {
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
                    Text("This is a list post!")
                    mediaList()
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
    
    private func mediaList(/* Add parameters */) -> some View {
        Grid {
            GridRow {
                Text("1")
                    .foregroundStyle(.secondary)
                    .font(.headline)
                CompactMediaView(title: "I Wanna Be Software", artist: "Grimes", enabled: false)
            }
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
    
    return List {
        SocialListPostView()
        SocialListPostView()
        SocialListPostView()
    }
    .environment(\.screenSize, screenSize)
    .listStyle(.plain)
}
