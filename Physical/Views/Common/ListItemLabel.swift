//
//  ListItemLabel.swift
//  Physical
//
//  Created by Spencer Hartland on 7/13/23.
//

import SwiftUI

struct ListItemLabel: View {
    private let iconSize: CGFloat = 28.0
    
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
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 6)
                    .foregroundStyle(color)
                    .aspectRatio(1.0, contentMode: .fill)
                symbol
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .padding(4)
                    .contentTransition(.symbolEffect(.replace))
            }
            .aspectRatio(1.0, contentMode: .fill)
            .frame(width: iconSize, height: iconSize)
        }
    }
}
