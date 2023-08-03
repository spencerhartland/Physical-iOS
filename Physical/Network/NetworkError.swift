//
//  NetworkError.swift
//  Physical
//
//  Created by Spencer Hartland on 8/3/23.
//

import Foundation

enum NetworkError: String, Error {
    case invalidURL = "The constructed URL is invalid."
    case invalidHTTPResponse = "The HTTP response is invalid or indicates error."
    case unsupportedImageType = "The image type is unsupported."
    case imageFetchError = "There was an issue fetching the image."
    case imageDataError = "There was an issue getting PNG data from the image."
    case imageDoesNotExist = "The requested image does not exist."
}
