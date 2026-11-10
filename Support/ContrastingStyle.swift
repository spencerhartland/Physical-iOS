//
//  ContrastingStyle.swift
//  Physical
//
//  Created by Spencer Hartland on 11/5/26.
//


import SwiftUI

struct ContrastingStyle: ShapeStyle {
    let background: Color

    func resolve(in environment: EnvironmentValues) -> Color {
        let backgroundY = ContrastCalculator.screenLuminance(of: background.resolve(in: environment))
        let lcBlack = abs(ContrastCalculator.lightnessContrast(textY: 0, backgroundY: backgroundY))
        let lcWhite = abs(ContrastCalculator.lightnessContrast(textY: 1, backgroundY: backgroundY))
        return lcBlack >= lcWhite ? .black : .white
    }
}

extension ShapeStyle where Self == ContrastingStyle {
    static func contrasting(with background: Color) -> ContrastingStyle {
        ContrastingStyle(background: background)
    }
}

struct ContrastCalculator {
    private static let mainTRC = 2.4
    private static let rCo = 0.2126729
    private static let gCo = 0.7151522
    private static let bCo = 0.0721750
    private static let normBG = 0.56
    private static let normTXT = 0.57
    private static let revBG = 0.65
    private static let revTXT = 0.62
    private static let blackThreshold = 0.022
    private static let blackClamp = 1.414
    private static let scale = 1.14
    private static let lowOffset = 0.027
    private static let deltaYMin = 0.0005
    private static let lowClip = 0.1

    static func screenLuminance(of color: Color.Resolved) -> Double {
        func encoded(_ linear: Float) -> Double {
            let v = Double(min(max(linear, 0), 1))
            return v <= 0.0031308 ? 12.92 * v : 1.055 * pow(v, 1 / 2.4) - 0.055
        }
        return rCo * pow(encoded(color.linearRed), mainTRC)
             + gCo * pow(encoded(color.linearGreen), mainTRC)
             + bCo * pow(encoded(color.linearBlue), mainTRC)
    }

    static func lightnessContrast(textY: Double, backgroundY: Double) -> Double {
        let txt = softClamp(textY)
        let bg = softClamp(backgroundY)
        guard abs(bg - txt) >= deltaYMin else { return 0 }

        if bg > txt {
            let sapc = (pow(bg, normBG) - pow(txt, normTXT)) * scale
            return sapc < lowClip ? 0 : (sapc - lowOffset) * 100
        } else {
            let sapc = (pow(bg, revBG) - pow(txt, revTXT)) * scale
            return sapc > -lowClip ? 0 : (sapc + lowOffset) * 100
        }
    }

    private static func softClamp(_ y: Double) -> Double {
        y > blackThreshold ? y : y + pow(blackThreshold - y, blackClamp)
    }
}
