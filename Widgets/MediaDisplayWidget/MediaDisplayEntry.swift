//
//  MediaEntry.swift
//  MediaWidgetExtension
//
//  Created by Spencer Hartland on 5/17/26.
//

import Foundation
import WidgetKit
import SwiftUI

struct MediaDisplayEntry: TimelineEntry {
    enum Content {
        case sample
        case media(MediaEntity)
        case noFavorites
    }
    
    let date: Date
    let content: Content
    let thumbnail: UIImage?
}
