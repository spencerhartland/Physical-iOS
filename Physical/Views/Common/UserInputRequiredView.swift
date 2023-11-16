//
//  UserInputRequiredView.swift
//  Physical
//
//  Created by Spencer Hartland on 11/8/23.
//

import SwiftUI

struct UserInputRequiredView<Content: View>: View {
    let symbolName: String
    let title: String
    let subtitle: String
    let content: Content
    
    @Environment(\.screenSize) private var screenSize: CGSize
    
    init(
        symbolName: String,
        title: String,
        subtitle: String,
        content: @escaping () -> Content
    ) {
        self.symbolName = symbolName
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: symbolName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: screenSize.width / 6)
            Text(title)
                .font(.title.bold())
            Text(subtitle)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .font(.callout)
                .padding(.vertical, 16)
            content
        }
        .padding(.horizontal)
    }
}
