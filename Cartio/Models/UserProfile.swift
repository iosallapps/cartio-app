//
//  UserProfile.swift
//  Cartio
//

import Foundation
import SwiftData

@Model
final class UserProfile: Codable {

    @Attribute(.unique) var id: UUID
    var firebaseUID: String
    var displayName: String
    var email: String
    var plan: SubscriptionPlan
    var avatarURL: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        firebaseUID: String = "",
        displayName: String = "",
        email: String = "",
        plan: SubscriptionPlan = .free,
        avatarURL: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.firebaseUID = firebaseUID
        self.displayName = displayName
        self.email = email
        self.plan = plan
        self.avatarURL = avatarURL
        self.createdAt = createdAt
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, firebaseUID, displayName, email, plan, avatarURL, createdAt
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        firebaseUID = try c.decode(String.self, forKey: .firebaseUID)
        displayName = try c.decode(String.self, forKey: .displayName)
        email = try c.decode(String.self, forKey: .email)
        plan = try c.decode(SubscriptionPlan.self, forKey: .plan)
        avatarURL = try c.decodeIfPresent(String.self, forKey: .avatarURL)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(firebaseUID, forKey: .firebaseUID)
        try c.encode(displayName, forKey: .displayName)
        try c.encode(email, forKey: .email)
        try c.encode(plan, forKey: .plan)
        try c.encode(avatarURL, forKey: .avatarURL)
        try c.encode(createdAt, forKey: .createdAt)
    }
}

// MARK: - Subscription Plan

enum SubscriptionPlan: String, Codable {
    case free
    case pro
    case team
}
