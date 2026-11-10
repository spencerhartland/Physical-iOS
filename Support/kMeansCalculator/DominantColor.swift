//
//  DominantColor.swift
//  Physical
//
//  Created by Spencer Hartland on 11/2/26.
//

import SwiftUI

/// A structure that represents a dominant color.
nonisolated struct DominantColor: Identifiable, Comparable, Sendable {
    var id: UUID
    let color: Color
    let percentage: Int
    
    init(_ centroid: DominantColorsCalculator.Centroid, totalPixelCount: Int) {
        let color = Color(red: Double(centroid.red), green: Double(centroid.green), blue: Double(centroid.blue))
        let percentage = Int(Float(centroid.pixelCount) / Float(totalPixelCount) * 100)
        
        self.init(color: color, percentage: percentage)
    }
    
    init(id: UUID = UUID(), color: Color, percentage: Int) {
        self.id = id
        self.color = color
        self.percentage = percentage
    }
    
    static func > (lhs: DominantColor, rhs: DominantColor) -> Bool {
        return lhs.percentage > rhs.percentage
    }
    
    static func < (lhs: DominantColor, rhs: DominantColor) -> Bool {
        return lhs.percentage < rhs.percentage
    }
}

extension DominantColor: Codable {
    private enum CodingKeys: String, CodingKey {
        case id
        case red
        case green
        case blue
        case percentage
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let id = try container.decode(UUID.self, forKey: .id)
        
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let color = Color(red: red, green: green, blue: blue)
        
        let percentage = try container.decode(Int.self, forKey: .percentage)
        
        self.init(id: id, color: color, percentage: percentage)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        
        let resolved = color.resolve(in: EnvironmentValues())
        try container.encode(Double(resolved.red), forKey: .red)
        try container.encode(Double(resolved.green), forKey: .green)
        try container.encode(Double(resolved.blue), forKey: .blue)
        
        try container.encode(percentage, forKey: .percentage)
    }
}
