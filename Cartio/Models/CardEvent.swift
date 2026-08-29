//
//  CardEvent.swift
//  Cartio
//
//  Tracks analytics events (views, shares, saves, link taps) per card.
//

import Foundation
import SwiftData

@Model
final class CardEvent {

    @Attribute(.unique) var id: UUID
    var cardID: UUID
    var type: CardEventType
    var timestamp: Date
    var metadata: [String: String]

    init(
        id: UUID = UUID(),
        cardID: UUID,
        type: CardEventType,
        timestamp: Date = .now,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.cardID = cardID
        self.type = type
        self.timestamp = timestamp
        self.metadata = metadata
    }
}

// MARK: - Event Type

enum CardEventType: String, Codable, CaseIterable {
    case view
    case share
    case save
    case linkTap

    var displayName: String {
        switch self {
        case .view: return "View"
        case .share: return "Share"
        case .save: return "Save"
        case .linkTap: return "Link Tap"
        }
    }

    var iconName: String {
        switch self {
        case .view: return "eye"
        case .share: return "square.and.arrow.up"
        case .save: return "square.and.arrow.down"
        case .linkTap: return "hand.tap"
        }
    }
}
