//
//  SocialProfilePostsView.swift
//  Physical
//
//  Created by Spencer Hartland on 8/24/23.
//

import SwiftUI

struct SocialProfilePostsView: View {
    let headerText = "Posts"
    
    @Environment(\.screenSize) private var screenSize: CGSize
    
    var body: some View {
        List {
            Section {
                SocialSimplePostView()
                SocialListPostView()
            } header: {
                Text(headerText)
                    .textCase(.none)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
            }
        }
        .listStyle(.plain)
        .scrollDisabled(true)
        .frame(width: screenSize.width, height: screenSize.height)
    }
}

#Preview {
    @Previewable @State var screenSize: CGSize = {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        return window.screen.bounds.size
    }()
    
    return ScrollView {
        VStack {
            SocialProfilePostsView()
        }
        .environment(\.screenSize, screenSize)
    }
}
