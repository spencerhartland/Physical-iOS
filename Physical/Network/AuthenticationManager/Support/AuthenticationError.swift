//
//  AuthenticationError.swift
//  Physical
//
//  Created by Spencer Hartland on 10/21/23.
//

import Foundation

enum AuthenticationError: String, Error {
    case invalidIDToken = "The provided identity token is invalid."
    case authenticationFailure = "Unable to authenticate with the provided identity token."
    case authenticationRequestFailure = "Unable to complete authentication request."
    case decodingResponseFailure = "There was a problem decoding the server's response to the authentication request."
    case couldNotCompleteRequest = "The request for authentication could not be completed."
    case authorizationCodeEncodeError = "An error occured while attempting to encode the authorization code."
    case invalidAuthorizationData = "The authorization data is invalid. Data required for authentication could not be obtained."
}
