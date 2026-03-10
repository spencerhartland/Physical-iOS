//
//  MediaEntry.swift
//  Physical
//
//  Created by Spencer Hartland on 1/26/26.
//

enum MediaEntryMethod {
    case manual
    case barcode
}

enum MediaEntryStep: Hashable {
    case albumSearch(MediaEntryMethod)
    case detailEdit
}
