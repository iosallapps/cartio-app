//
//  BusinessCard.swift
//  Cartio
//
//  Core domain model + SwiftData persistence.
//  Also Codable for Firebase serialization.
//

import Foundation
import SwiftData

@Model
final class BusinessCard: Codable {

    @Attribute(.unique) var id: UUID
    var name: String
    var title: String
    var company: String
    var email: String
    var phone: String
    var website: String
    var bio: String

    var templateID: String
    var socialLinks: [String: String]
    var colorHex: String

    var avatarImageURL: String?
    var logoImageURL: String?

    var isDefault: Bool
    var isArchived: Bool

    var createdAt: Date
    var updatedAt: Date

    var firebaseDocID: String?

    init(
        id: UUID = UUID(),
        name: String = "",
        title: String = "",
        company: String = "",
        email: String = "",
        phone: String = "",
        website: String = "",
        bio: String = "",
        templateID: String = CardTemplate.classic.id,
        socialLinks: [String: String] = [:],
        colorHex: String = "#0A7E8C",
        avatarImageURL: String? = nil,
        logoImageURL: String? = nil,
        isDefault: Bool = false,
        isArchived: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        firebaseDocID: String? = nil
    ) {
        self.id = id
        self.name = name
        self.title = title
        self.company = company
        self.email = email
        self.phone = phone
        self.website = website
        self.bio = bio
        self.templateID = templateID
        self.socialLinks = socialLinks
        self.colorHex = colorHex
        self.avatarImageURL = avatarImageURL
        self.logoImageURL = logoImageURL
        self.isDefault = isDefault
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.firebaseDocID = firebaseDocID
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, name, title, company, email, phone, website, bio
        case templateID, socialLinks, colorHex
        case avatarImageURL, logoImageURL
        case isDefault, isArchived, createdAt, updatedAt, firebaseDocID
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        title = try c.decode(String.self, forKey: .title)
        company = try c.decode(String.self, forKey: .company)
        email = try c.decode(String.self, forKey: .email)
        phone = try c.decode(String.self, forKey: .phone)
        website = try c.decode(String.self, forKey: .website)
        bio = try c.decode(String.self, forKey: .bio)
        templateID = try c.decode(String.self, forKey: .templateID)
        socialLinks = try c.decode([String: String].self, forKey: .socialLinks)
        colorHex = try c.decode(String.self, forKey: .colorHex)
        avatarImageURL = try c.decodeIfPresent(String.self, forKey: .avatarImageURL)
        logoImageURL = try c.decodeIfPresent(String.self, forKey: .logoImageURL)
        isDefault = try c.decode(Bool.self, forKey: .isDefault)
        isArchived = try c.decode(Bool.self, forKey: .isArchived)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        updatedAt = try c.decode(Date.self, forKey: .updatedAt)
        firebaseDocID = try c.decodeIfPresent(String.self, forKey: .firebaseDocID)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(title, forKey: .title)
        try c.encode(company, forKey: .company)
        try c.encode(email, forKey: .email)
        try c.encode(phone, forKey: .phone)
        try c.encode(website, forKey: .website)
        try c.encode(bio, forKey: .bio)
        try c.encode(templateID, forKey: .templateID)
        try c.encode(socialLinks, forKey: .socialLinks)
        try c.encode(colorHex, forKey: .colorHex)
        try c.encode(avatarImageURL, forKey: .avatarImageURL)
        try c.encode(logoImageURL, forKey: .logoImageURL)
        try c.encode(isDefault, forKey: .isDefault)
        try c.encode(isArchived, forKey: .isArchived)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(updatedAt, forKey: .updatedAt)
        try c.encode(firebaseDocID, forKey: .firebaseDocID)
    }
}
