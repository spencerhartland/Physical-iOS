//
//  User.swift
//  Physical
//
//  Created by Spencer Hartland on 9/19/23.
//

import Foundation
import SwiftData

@Model
final class User: Codable {
    /// The unique user identifier assigned to the user by Apple.
    var userID: String
    /// The unique username chosen by the user.
    var username: String
    /// The user's chosen display name.
    var displayName: String
    /// The user's biography.
    var biography: String
    /// The unique user identifiers of the user's followers.
    var followers: [String]
    /// The unique user identifiers of the user's followed accounts.
    var following: [String]
    /// The Music Item ID of the user's featured Music Item.
    var featured: String
    /// The unique identifier of the user's collection.
    var collection: String
    /// The unique identifiers of the user's authored posts.
    var posts: [String]
    /// The URL for the user's chosen cover photo.
    var coverPhotoURL: String
    /// The URL for the user's chosen profile photo.
    var profilePhotoURL: String
    
    /// Creates an instance of `User`.
    ///
    /// - Parameters:
    ///   - userID: The unique user identifier assigned to the user by Apple.
    ///   - username: The unique username chosen by the user.
    ///   - collection: The unique identifier of the user's collection.
    init(with userID: String, username: String, collection: String) {
        self.userID = userID
        self.username = username
        self.displayName = ""
        self.biography = ""
        self.followers = []
        self.following = []
        self.featured = ""
        self.collection = collection
        self.posts = []
        self.coverPhotoURL = ""
        self.profilePhotoURL = ""
    }
    
    // MARK: - Codable conformance
    
    // Keys used to encode and decode properties
    enum CodingKeys: CodingKey {
        case userID, username, displayName, biography, followers, following, featured, collection, posts, coverPhotoURL, profilePhotoURL
    }
    
    // Decodable conformance initializer
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userID = try container.decode(String.self, forKey: .userID)
        self.username = try container.decode(String.self, forKey: .username)
        self.displayName = try container.decode(String.self, forKey: .displayName)
        self.biography = try container.decode(String.self, forKey: .biography)
        self.followers = try container.decode([String].self, forKey: .followers)
        self.following = try container.decode([String].self, forKey: .following)
        self.featured = try container.decode(String.self, forKey: .featured)
        self.collection = try container.decode(String.self, forKey: .collection)
        self.posts = try container.decode([String].self, forKey: .posts)
        self.coverPhotoURL = try container.decode(String.self, forKey: .coverPhotoURL)
        self.profilePhotoURL = try container.decode(String.self, forKey: .profilePhotoURL)
    }
    
    // Encodable conformance method
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userID, forKey: .userID)
        try container.encode(self.username, forKey: .username)
        try container.encode(self.displayName, forKey: .displayName)
        try container.encode(self.biography, forKey: .biography)
        try container.encode(self.followers, forKey: .followers)
        try container.encode(self.following, forKey: .following)
        try container.encode(self.featured, forKey: .featured)
        try container.encode(self.collection, forKey: .collection)
        try container.encode(self.posts, forKey: .posts)
        try container.encode(self.coverPhotoURL, forKey: .coverPhotoURL)
        try container.encode(self.profilePhotoURL, forKey: .profilePhotoURL)
    }
}
