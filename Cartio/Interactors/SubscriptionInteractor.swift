//
//  SubscriptionInteractor.swift
//  Cartio
//

import Foundation
import StoreKit

final class SubscriptionInteractor: SubscriptionInteractorProtocol {

    var isPremium: Bool { subscriptionService.isPremium }

    private let subscriptionService: SubscriptionServiceProtocol

    init(subscriptionService: SubscriptionServiceProtocol) {
        self.subscriptionService = subscriptionService
    }

    func fetchProducts() async throws -> [Product] {
        try await subscriptionService.fetchProducts()
    }

    func purchase(_ product: Product) async throws {
        _ = try await subscriptionService.purchase(product)
    }

    func restorePurchases() async throws {
        try await subscriptionService.restorePurchases()
    }

    func canAccess(_ feature: PremiumFeature) -> Bool {
        if isPremium { return true }

        // Free tier access
        switch feature {
        case .unlimitedCards, .premiumTemplates, .nfcWrite, .appleWallet,
             .advancedAnalytics, .unlimitedScans, .contactExport,
             .emailSignature, .customQRColors:
            return false
        }
    }
}
