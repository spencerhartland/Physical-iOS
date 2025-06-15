//
//  testView.swift
//  Physical
//
//  Created by Spencer Hartland on 4/1/25.
//

import SwiftUI

struct testView: View {
    var body: some View {
        ZStack {
            Color(UIColor.secondarySystemBackground)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading) {
                    caption("Large Title")
                    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                        .font(.largeTitle)
                    caption("Title")
                    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                        .font(.title)
                    caption("Title 2")
                    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                        .font(.title2)
                    caption("Title 3")
                    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                        .font(.title3)
                    caption("Headline")
                    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                        .font(.headline)
                    caption("Subheadline")
                    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                        .font(.subheadline)
                    caption("Callout")
                    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                        .font(.callout)
                    caption("Caption")
                    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                        .font(.caption)
                    caption("Caption 2")
                    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                        .font(.caption2)
                    caption("Footnote")
                    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                        .font(.footnote)
                }
                
                VStack(alignment: .leading) {
                    caption("System Fill")
                    Rectangle()
                        .frame(width: 128, height: 28)
                        .foregroundStyle(Color(UIColor.systemFill))
                    caption("Secondary System Fill")
                    Rectangle()
                        .frame(width: 128, height: 28)
                        .foregroundStyle(Color(UIColor.secondarySystemFill))
                    caption("Tertiary System Fill")
                    Rectangle()
                        .frame(width: 128, height: 28)
                        .foregroundStyle(Color(UIColor.tertiarySystemFill))
                    caption("Quaternary System Fill")
                    Rectangle()
                        .frame(width: 128, height: 28)
                        .foregroundStyle(Color(UIColor.quaternarySystemFill))
                }
                
            }
            .foregroundStyle(.primary)
            .background(Color(UIColor.secondarySystemBackground))
        }
    }
    
    private func caption(_ name: String) -> some View {
        Text(name)
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    testView()
}
