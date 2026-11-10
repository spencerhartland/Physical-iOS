//
//  PlaceholderView.swift
//  PhysicalMediaWidgetExtension
//
//  Created by Spencer Hartland on 11/1/26.
//

import SwiftUI

struct PlaceholderView: View {
    var body: some View {
        VStack {
            Image(systemName: "heart.slash.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
            
            Text("No Favorites!")
                .font(.subheadline.bold())
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
