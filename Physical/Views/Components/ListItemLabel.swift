//
//  ListItemLabel.swift
//  Physical
//
//  Created by Spencer Hartland on 7/13/23.
//

import SwiftUI

struct ListItemLabel: View {
    let color: Color
    let symbol: Image
    let labelText: String
    
    init(color: Color, symbolName: String, labelText: String) {
        self.color = color
        self.symbol = Image(systemName: symbolName)
        self.labelText = labelText
    }
    
    init(color: Color, symbol: ImageResource, labelText: String) {
        self.color = color
        self.symbol = Image(symbol)
        self.labelText = labelText
    }
    
    init(color: Color, symbol: Image, labelText: String) {
        self.color = color
        self.symbol = symbol
        self.labelText = labelText
    }
    
    var body: some View {
        Label {
            Text(labelText)
        } icon: {
            RoundedRectangle(cornerRadius: 6)
                .aspectRatio(1.0, contentMode: .fit)
                .foregroundStyle(color)
                .overlay {
                    symbol
                        .resizable()
                        .foregroundStyle(.white)
                        .aspectRatio(contentMode: .fit)
                        .padding(4)
                }
        }
    }
}
