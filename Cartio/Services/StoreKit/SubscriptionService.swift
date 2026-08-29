//
//  SubscriptionService.swift
//  Cartio
//
//  StoreKit 2 subscription management.
//

import Foundation
import StoreKit
import Combine

final class SubscriptionService: SubscriptionServiceProtocol {

    var isPremium: Bool { _isPremium }
    var isPremiumPublisher: AnyPublisher<Bool, Never> { _premiumSubject.eraseToAnyPublisher() }

    private var _isPremium = false
    private let _premiumSubject = CurrentValueSubject<Bool, Never>(false)
    private var transactionTask: Task<Void, Never>?

    func fetchProducts() async throws -> [Product] {
        try await Product.products(for: AppConstants.Products.all)
    }

    func purchase(_ product: Product) async throws -> Transaction {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerification(verification)
            await transaction.finish()
            await updatePremiumStatus()
            return transaction

        case .userCancelled:
            throw CartioError.purchaseFailed("Purchase cancelled.")

        case .pending:
            throw CartioError.purchaseFailed("Purchase is pending approval.")

        @unknown default:
            throw CartioError.purchaseFailed("Unknown purchase result.")
        }
    }

    func restorePurchases() async throws {
        try await AppStore.sync()
        await updatePremiumStatus()
    }

    func startTransactionListener() {
        transactionTask = Task(priority: .background) {
            for await result in Transaction.updates {
                if let transaction = try? checkVerification(result) {
                    await transaction.finish()
                    await updatePremiumStatus()
                }
            }
        }
    }

    // MARK: - Private

    private func checkVerification(_ result: VerificationResult<Transaction>) throws -> Transaction {
        switch result {
        case .verified(let transaction):
            return transaction
        case .unverified:
            throw CartioError.purchaseFailed("Transaction verification failed.")
        }
    }

    private func updatePremiumStatus() async {
        var premium = false

        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerification(result) {
                if AppConstants.Products.all.contains(transaction.productID) {
                    premium = true
                    break
                }
            }
        }

        _isPremium = premium
        _premiumSubject.send(premium)

        // Cache for offline access
        UserDefaults.standard.set(premium, forKey: "cartio_is_premium_cached")
    }
}
