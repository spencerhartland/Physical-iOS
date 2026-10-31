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
    let date: Date
    let configuration: SelectMediaIntent
    let thumbnailKey: String
}
