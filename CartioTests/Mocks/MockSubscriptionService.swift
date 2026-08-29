//
//  MockSubscriptionService.swift
//  CartioTests
//

import Foundation
import Combine
import StoreKit
@testable import Cartio

@MainActor
final class MockSubscriptionService: SubscriptionServiceProtocol {

    var _isPremium = false
    var isPremium: Bool { _isPremium }
    var isPremiumPublisher: AnyPublisher<Bool, Never> {
        Just(_isPremium).eraseToAnyPublisher()
    }

    func fetchProducts() async throws -> [Product] { [] }
    func purchase(_ product: Product) async throws -> Transaction {
        fatalError("Not implemented in mock")
    }
    func restorePurchases() async throws {}
    func startTransactionListener() {}
}
