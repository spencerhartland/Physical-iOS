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
    let labelText: LocalizedStringResource
    let labelFontWeight: Font.Weight
    
    init(
        color: Color,
        symbolName: String,
        labelText: LocalizedStringResource,
        labelFontWeight: Font.Weight = .regular
    ) {
        self.color = color
        self.symbol = Image(systemName: symbolName)
        self.labelText = labelText
        self.labelFontWeight = labelFontWeight
    }
    
    init(
        color: Color,
        symbol: ImageResource,
        labelText: LocalizedStringResource,
        labelFontWeight: Font.Weight = .regular
    ) {
        self.color = color
        self.symbol = Image(symbol)
        self.labelText = labelText
        self.labelFontWeight = labelFontWeight
    }
    
    init(
        color: Color,
        symbol: Image,
        labelText: LocalizedStringResource,
        labelFontWeight: Font.Weight = .regular
    ) {
        self.color = color
        self.symbol = symbol
        self.labelText = labelText
        self.labelFontWeight = labelFontWeight
    }
    
    var body: some View {
        Label {
            Text(labelText)
                .fontWeight(labelFontWeight)
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
