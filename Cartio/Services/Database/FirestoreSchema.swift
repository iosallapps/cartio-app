//
//  FirestoreSchema.swift
//  Cartio
//
//  Single source of truth for all Firestore collection paths.
//

import Foundation

enum FirestoreSchema {

    // users/{uid}
    static func userDocument(uid: String) -> String {
        "\(AppConstants.Collections.users)/\(uid)"
    }

    // users/{uid}/cards/{cardId}
    static func cardDocument(uid: String, cardId: String) -> String {
        "\(AppConstants.Collections.users)/\(uid)/\(AppConstants.Collections.cards)/\(cardId)"
    }

    static func cardsCollection(uid: String) -> String {
        "\(AppConstants.Collections.users)/\(uid)/\(AppConstants.Collections.cards)"
    }

    // users/{uid}/contacts/{contactId}
    static func contactDocument(uid: String, contactId: String) -> String {
        "\(AppConstants.Collections.users)/\(uid)/\(AppConstants.Collections.contacts)/\(contactId)"
    }

    static func contactsCollection(uid: String) -> String {
        "\(AppConstants.Collections.users)/\(uid)/\(AppConstants.Collections.contacts)"
    }

    // users/{uid}/shareLinks/{linkId}
    static func shareLinkDocument(uid: String, linkId: String) -> String {
        "\(AppConstants.Collections.users)/\(uid)/\(AppConstants.Collections.shareLinks)/\(linkId)"
    }

    // analytics/{linkId}/events/{eventId}
    static func analyticsCollection(linkId: String) -> String {
        "\(AppConstants.Collections.analytics)/\(linkId)/events"
    }
}
