//
//  Contact.swift
//  Cartio
//

import Foundation
import SwiftData

@Model
final class Contact: Codable {

    @Attribute(.unique) var id: UUID
    var name: String
    var title: String?
    var company: String?
    var email: String?
    var phone: String?
    var website: String?
    var notes: String?

    var source: ContactSource
    var scannedCardImageURL: String?

    var isFavorite: Bool

    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .nullify) var tags: [ContactTag]

    init(
        id: UUID = UUID(),
        name: String = "",
        title: String? = nil,
        company: String? = nil,
        email: String? = nil,
        phone: String? = nil,
        website: String? = nil,
        notes: String? = nil,
        source: ContactSource = .manual,
        scannedCardImageURL: String? = nil,
        isFavorite: Bool = false,
        tags: [ContactTag] = [],
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.title = title
        self.company = company
        self.email = email
        self.phone = phone
        self.website = website
        self.notes = notes
        self.source = source
        self.scannedCardImageURL = scannedCardImageURL
        self.isFavorite = isFavorite
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, name, title, company, email, phone, website, notes
        case source, scannedCardImageURL, isFavorite, createdAt, updatedAt
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        title = try c.decodeIfPresent(String.self, forKey: .title)
        company = try c.decodeIfPresent(String.self, forKey: .company)
        email = try c.decodeIfPresent(String.self, forKey: .email)
        phone = try c.decodeIfPresent(String.self, forKey: .phone)
        website = try c.decodeIfPresent(String.self, forKey: .website)
        notes = try c.decodeIfPresent(String.self, forKey: .notes)
        source = try c.decode(ContactSource.self, forKey: .source)
        scannedCardImageURL = try c.decodeIfPresent(String.self, forKey: .scannedCardImageURL)
        isFavorite = try c.decode(Bool.self, forKey: .isFavorite)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        updatedAt = try c.decode(Date.self, forKey: .updatedAt)
        tags = []
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
        try c.encode(notes, forKey: .notes)
        try c.encode(source, forKey: .source)
        try c.encode(scannedCardImageURL, forKey: .scannedCardImageURL)
        try c.encode(isFavorite, forKey: .isFavorite)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(updatedAt, forKey: .updatedAt)
    }
}

// MARK: - Contact Source

enum ContactSource: String, Codable {
    case scanned
    case shared
    case manual
    case imported
}
