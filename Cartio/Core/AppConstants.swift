//
//  AppConstants.swift
//  Cartio
//

import Foundation

enum AppConstants {

    // MARK: - URLs

    enum URLs {
        static let baseURL = "https://cartio.me"
        static let apiBaseURL = "https://api.cartio.me"
    }

    // MARK: - Free Tier Limits

    enum FreeTier {
        static let maxCards = 2
        static let maxTemplates = 8
        static let maxOCRScansPerMonth = 10
    }

    // MARK: - StoreKit Product IDs

    enum Products {
        static let proMonthly = "com.cartio.pro.monthly"
        static let proYearly = "com.cartio.pro.yearly"
        static let proLifetime = "com.cartio.pro.lifetime"

        static let all: Set<String> = [proMonthly, proYearly, proLifetime]
    }

    // MARK: - App Group

    static let appGroupID = "group.com.cartio.app"

    // MARK: - Firebase Collections

    enum Collections {
        static let users = "users"
        static let cards = "cards"
        static let contacts = "contacts"
        static let shareLinks = "shareLinks"
        static let analytics = "analytics"
    }

    // MARK: - Image Limits

    enum Images {
        static let maxSizeBytes = 500_000 // 500KB
        static let avatarSize: CGFloat = 400
        static let logoSize: CGFloat = 200
    }
}
