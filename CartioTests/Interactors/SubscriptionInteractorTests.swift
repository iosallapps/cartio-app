//
//  SubscriptionInteractorTests.swift
//  CartioTests
//

import Testing
import Foundation
@testable import Cartio

@MainActor
struct SubscriptionInteractorTests {

    // MARK: - Helpers

    private func makeSUT(isPremium: Bool = false) -> (SubscriptionInteractor, MockSubscriptionService) {
        let service = MockSubscriptionService()
        service._isPremium = isPremium
        let interactor = SubscriptionInteractor(subscriptionService: service)
        return (interactor, service)
    }

    // MARK: - Premium Status

    @Test func isPremium_returnsFalseByDefault() {
        let (sut, _) = makeSUT()
        #expect(sut.isPremium == false)
    }

    @Test func isPremium_returnsTrueWhenSubscribed() {
        let (sut, _) = makeSUT(isPremium: true)
        #expect(sut.isPremium == true)
    }

    // MARK: - Feature Access

    @Test func canAccess_freeUserDeniedPremiumFeatures() {
        let (sut, _) = makeSUT()

        let premiumFeatures: [PremiumFeature] = [
            .unlimitedCards, .premiumTemplates, .nfcWrite,
            .appleWallet, .advancedAnalytics, .unlimitedScans,
            .contactExport, .emailSignature, .customQRColors
        ]

        for feature in premiumFeatures {
            #expect(sut.canAccess(feature) == false, "Free user should not access \(feature)")
        }
    }

    @Test func canAccess_premiumUserAccessesAll() {
        let (sut, _) = makeSUT(isPremium: true)

        let allFeatures: [PremiumFeature] = [
            .unlimitedCards, .premiumTemplates, .nfcWrite,
            .appleWallet, .advancedAnalytics, .unlimitedScans,
            .contactExport, .emailSignature, .customQRColors
        ]

        for feature in allFeatures {
            #expect(sut.canAccess(feature) == true, "Premium user should access \(feature)")
        }
    }
}
