//
//  MediaColorCodeViewModifier.swift
//  Physical
//
//  Created by Spencer Hartland on 2/12/26.
//

import SwiftUI

extension View {
    func colorCode(for rarity: Rarity) -> some View {
        return self.modifier(MediaColorCodeViewModifier(for: rarity))
    }
}

struct MediaColorCodeViewModifier: ViewModifier {

    private var rarity: Rarity
    private var colorSet: ColorSet
    
    init(for rarity: Rarity) {
        self.rarity = rarity
        
        switch rarity {
        case .common:
            self.colorSet = CommonColorSet()
        case .uncommon:
            self.colorSet = UncommonColorSet()
        case .rare:
            self.colorSet = RareColorSet()
        case .legendary:
            self.colorSet = LegendaryColorSet()
        case .unique:
            self.colorSet = UniqueColorSet()
        }
    }
    
    func body(content: Content) -> some View {
        VStack {
            content
                .background {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(LinearGradient(
                                stops: [
                                    .init(
                                        color: colorSet.primaryBackgroundColor,
                                        location: 0.0),
                                    .init(
                                        color: colorSet.secondaryBackgroundColor,
                                        location: 1.0)
                                ],
                                startPoint: .bottom,
                                endPoint: .top))
                            .shadow(radius: 4)
                        RoundedRectangle(cornerRadius: 24)
                            .fill(MeshGradient(
                                width: 3,
                                height: 4,
                                points: [
                                    [0, 0],[0.5, 0],[1, 0],
                                    [0, 0.35],[0.25, 0.15],[1, 0.35],
                                    [0, 0.75],[0.75, 0.85],[1, 0.65],
                                    [0, 1],[0.5, 1],[1, 1]
                                ],
                                colors: [
                                    colorSet.primaryColor, colorSet.secondaryColor, .clear,
                                    .clear, .clear, .clear,
                                    .clear, .clear, .clear,
                                    colorSet.secondaryColor, colorSet.primaryColor, colorSet.primaryColor,
                                ])
                                .shadow(.inner(color: colorSet.borderColor, radius: 16))
                            )
                            .strokeBorder(
                                MeshGradient(
                                    width: 3,
                                    height: 4,
                                    points: [
                                        [0, 0],[0.5, 0],[1, 0],
                                        [0, 0.5],[0.5, 0.5],[1, 0.5],
                                        [0, 0.75],[0.5, 0.75],[1, 0.75],
                                        [0, 1],[0.5, 1],[1, 1]
                                    ],
                                    colors: [
                                        .clear, .clear, colorSet.borderColor,
                                        colorSet.borderColor, .clear, .clear,
                                        colorSet.borderColor, .clear, .clear,
                                        colorSet.borderColor, colorSet.borderColor, colorSet.borderColor,
                                    ]),
                                lineWidth: 2)
                    }
                }
        }
        .aspectRatio(5/7, contentMode: .fit)
    }
}

extension MediaColorCodeViewModifier {
    private protocol ColorSet {
        var primaryColor: Color { get }
        var secondaryColor: Color { get }
        var borderColor: Color { get }
        var primaryBackgroundColor: Color { get }
        var secondaryBackgroundColor: Color { get }
    }
    
    struct CommonColorSet: ColorSet {
        let primaryColor = Color(
            hue: 0/360,
            saturation: 0.0,
            brightness: 0.95,
            opacity: 1.0)
        let secondaryColor = Color(
            hue: 0/360,
            saturation: 0.0,
            brightness: 0.95,
            opacity: 0.85)
        let borderColor = Color(
            hue: 0/360,
            saturation: 0.0,
            brightness: 0.95,
            opacity: 1.0)
        let primaryBackgroundColor = Color(
            hue: 0/360,
            saturation: 0.0,
            brightness: 0.45,
            opacity: 1.0)
        let secondaryBackgroundColor = Color(
            hue: 0/360,
            saturation: 0.0,
            brightness: 0.80,
            opacity: 1.0)
    }
    
    struct UncommonColorSet: ColorSet {
        let primaryColor = Color(
            hue: 218/360,
            saturation: 0.95,
            brightness: 0.95,
            opacity: 1.0)
        let secondaryColor = Color(
            hue: 218/360,
            saturation: 0.95,
            brightness: 0.95,
            opacity: 0.40)
        let borderColor = Color(
            hue: 218/360,
            saturation: 0.95,
            brightness: 0.95,
            opacity: 1.0)
        let primaryBackgroundColor = Color(
            hue: 218/360,
            saturation: 0.95,
            brightness: 0.15,
            opacity: 1.0)
        let secondaryBackgroundColor = Color(
            hue: 218/360,
            saturation: 0.95,
            brightness: 0.35,
            opacity: 1.0)
    }
    
    struct RareColorSet: ColorSet {
        let primaryColor = Color(
            hue: 270/360,
            saturation: 0.95,
            brightness: 0.95,
            opacity: 1.0)
        let secondaryColor = Color(
            hue: 270/360,
            saturation: 0.95,
            brightness: 0.95,
            opacity: 0.40)
        let borderColor = Color(
            hue: 270/360,
            saturation: 0.95,
            brightness: 0.95,
            opacity: 1.0)
        let primaryBackgroundColor = Color(
            hue: 270/360,
            saturation: 0.95,
            brightness: 0.15,
            opacity: 1.0)
        let secondaryBackgroundColor = Color(
            hue: 270/360,
            saturation: 0.95,
            brightness: 0.35,
            opacity: 1.0)
    }
    
    struct LegendaryColorSet: ColorSet {
        let primaryColor = Color(
            hue: 36/360,
            saturation: 0.65,
            brightness: 0.85,
            opacity: 1.0)
        let secondaryColor = Color(
            hue: 36/360,
            saturation: 0.65,
            brightness: 0.85,
            opacity: 0.40)
        let borderColor = Color(
            hue: 36/360,
            saturation: 0.35,
            brightness: 0.95,
            opacity: 1.0)
        let primaryBackgroundColor = Color(
            hue: 36/360,
            saturation: 0.85,
            brightness: 0.35,
            opacity: 1.0)
        let secondaryBackgroundColor = Color(
            hue: 36/360,
            saturation: 0.55,
            brightness: 0.75,
            opacity: 1.0)
    }
    
    struct UniqueColorSet: ColorSet {
        let primaryColor = Color(
            hue: 0/360,
            saturation: 0.95,
            brightness: 0.85,
            opacity: 1.0)
        let secondaryColor = Color(
            hue: 0/360,
            saturation: 0.95,
            brightness: 0.85,
            opacity: 0.40)
        let borderColor = Color(
            hue: 0/360,
            saturation: 0.95,
            brightness: 0.85,
            opacity: 1.0)
        let primaryBackgroundColor = Color(
            hue: 0/360,
            saturation: 0.95,
            brightness: 0.25,
            opacity: 1.0)
        let secondaryBackgroundColor = Color(
            hue: 0/360,
            saturation: 0.95,
            brightness: 0.50,
            opacity: 1.0)
    }
}
