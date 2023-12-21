//
//  UserAccountError.swift
//  Physical
//
//  Created by Spencer Hartland on 12/21/23.
//

import Foundation

enum UserAccountError: String, Error {
    case fetchRequestError = "There was a problem while attempting to fetch the requested user account."
    case creationRequestError = "There was a problem while attempting to create the user account."
    case responseDecodeError = "There was a problem while getting the response status and / or data."
    case requestDataEncodeError = "There was a problem while attempting to encode the request data."
}
