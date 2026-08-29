//
//  MockSubscriptionInteractor.swift
//  CartioTests
//

import Foundation
import StoreKit
@testable import Cartio

@MainActor
final class MockSubscriptionInteractor: SubscriptionInteractorProtocol {

    var isPremium: Bool = false

    func fetchProducts() async throws -> [Product] { [] }
    func purchase(_ product: Product) async throws {}
    func restorePurchases() async throws {}

    func canAccess(_ feature: PremiumFeature) -> Bool {
        isPremium
    }
}
