//
//  User.swift
//  Physical
//
//  Created by Spencer Hartland on 9/19/23.
//

import Foundation
import SwiftData

@Model
final class User {
    /// The unique user identifier assigned to the user by Apple.
    private let userID: String
    /// The unique username chosen by the user.
    private var username: String
    /// The user's chosen display name.
    private var displayName: String
    /// The user's biography.
    private var biography: String?
    /// The unique user identifiers of the user's followers.
    private var followers: [String]
    /// The unique user identifiers of the user's followed accounts.
    private var following: [String]
    /// The Music Item ID of the user's featured Music Item.
    private var featured: String?
    /// The unique identifier of the user's collection.
    private var collection: String
    /// The unique identifiers of the user's authored posts.
    private var posts: [String]
    
    
    init(with userID: String, username: String, displayName: String, collection: String) {
        self.userID = userID
        self.username = username
        self.displayName = displayName
        self.biography = nil
        self.followers = []
        self.following = []
        self.featured = nil
        self.collection = collection
        self.posts = []
    }
}
