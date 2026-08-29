//
//  SubscriptionServiceProtocol.swift
//  Cartio
//

import Foundation
import Combine
import StoreKit

@MainActor
protocol SubscriptionServiceProtocol {
    var isPremium: Bool { get }
    var isPremiumPublisher: AnyPublisher<Bool, Never> { get }

    func fetchProducts() async throws -> [Product]
    func purchase(_ product: Product) async throws -> Transaction
    func restorePurchases() async throws
    func startTransactionListener()
}
