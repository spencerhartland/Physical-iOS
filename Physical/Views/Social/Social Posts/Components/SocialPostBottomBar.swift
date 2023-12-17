//
//  SocialPostBottomBar.swift
//  Physical
//
//  Created by Spencer Hartland on 8/27/23.
//

import SwiftUI

struct SocialPostBottomBar: View {
    var body: some View {
        HStack(spacing: 16) {
            Button {
                
            } label: {
                label(value: 500, systemImage: "heart")
            }
            Button {
                
            } label: {
                label(value: 150, systemImage: "bubble.left.and.bubble.right")
            }
            Spacer()
            Button {
                
            } label: {
                Image(systemName: "ellipsis")
            }
        }
        .font(.system(size: 16).weight(.medium))
    }
    
    private func label(value: Int, systemImage: String) -> some View {
        HStack {
            Image(systemName: systemImage)
            Text("\(value)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    SocialPostBottomBar()
}
