//
//  SubscriptionInteractorProtocol.swift
//  Cartio
//

import Foundation
import StoreKit

enum PremiumFeature {
    case unlimitedCards
    case premiumTemplates
    case nfcWrite
    case appleWallet
    case advancedAnalytics
    case unlimitedScans
    case contactExport
    case emailSignature
    case customQRColors
}

@MainActor
protocol SubscriptionInteractorProtocol {
    var isPremium: Bool { get }

    func fetchProducts() async throws -> [Product]
    func purchase(_ product: Product) async throws
    func restorePurchases() async throws
    func canAccess(_ feature: PremiumFeature) -> Bool
}
