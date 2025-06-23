//
//  testView.swift
//  Physical
//
//  Created by Spencer Hartland on 4/1/25.
//

import SwiftUI

struct testView: View {
    var body: some View {
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
            
            Grid {
                GridRow {
                    caption("Sys Fill")
                    caption("2nd Sys Fill")
                    caption("3rd Sys Fill")
                    caption("4th Sys Fill")
                }
                GridRow {
                    swatch(.systemFill)
                    swatch(.secondarySystemFill)
                    swatch(.tertiarySystemFill)
                    swatch(.quaternarySystemFill)
                }
                
                Divider()
                
                GridRow {
                    caption("Sys Bg")
                    caption("2nd Sys Bg")
                    caption("3rd Sys Bg")
                    caption("NA")
                }
                GridRow {
                    swatch(.systemBackground)
                    swatch(.secondarySystemBackground)
                    swatch(.tertiarySystemBackground)
                    swatch(.clear)
                }
                
                Divider()
                
                GridRow {
                    caption("Sys Grp'd Bg")
                    caption("2nd Grp'd Sys Bg")
                    caption("3rd Grp'd Sys Bg")
                    caption("NA")
                }
                GridRow {
                    swatch(.systemGroupedBackground)
                    swatch(.secondarySystemGroupedBackground)
                    swatch(.tertiarySystemGroupedBackground)
                    swatch(.clear)
                }
            }
        }
        .padding(8)
        .frame(maxHeight: .infinity)
        .background {
            Color(UIColor.secondarySystemBackground)
                .ignoresSafeArea()
        }
    }
    
    private func caption(_ name: String) -> some View {
        Text(name)
            .font(.caption)
            .foregroundStyle(.secondary)
    }
    
    private func swatch(_ color: UIColor) -> some View {
        Rectangle()
            .frame(height: 28)
            .foregroundStyle(Color(color))
    }
}

#Preview {
    testView()
}
