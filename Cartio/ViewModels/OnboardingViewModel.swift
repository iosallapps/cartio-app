//
//  OnboardingViewModel.swift
//  Cartio
//

import Foundation
import UIKit
import SwiftUI
import StoreKit

@Observable
final class OnboardingViewModel {

    var currentPage = 0
    var name = ""
    var title = ""
    var company = ""
    var email = ""
    var phone = ""
    var isCreatingCard = false
    var isPurchasing = false
    var selectedPlan: String = AppConstants.Products.proYearly
    var error: CartioError?

    private let cardInteractor: CardInteractorProtocol
    private let subscriptionInteractor: SubscriptionInteractorProtocol

    init(cardInteractor: CardInteractorProtocol, subscriptionInteractor: SubscriptionInteractorProtocol) {
        self.cardInteractor = cardInteractor
        self.subscriptionInteractor = subscriptionInteractor
    }

    var isNameValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    func nextPage() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        withAnimation { currentPage += 1 }
    }

    func createFirstCard() async {
        guard isNameValid else { return }
        isCreatingCard = true
        defer { isCreatingCard = false }

        do {
            _ = try await cardInteractor.createCard(
                name: name,
                title: title,
                company: company,
                email: email,
                phone: phone,
                templateID: CardTemplate.classic.id
            )
            nextPage()
        } catch let err as CartioError {
            error = err
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    func skipCardCreation() {
        nextPage()
    }

    func purchaseSelectedPlan() async {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let products = try await subscriptionInteractor.fetchProducts()
            guard let product = products.first(where: { $0.id == selectedPlan }) else {
                error = .productNotFound
                return
            }
            try await subscriptionInteractor.purchase(product)
        } catch let err as CartioError {
            error = err
        } catch {
            self.error = .purchaseFailed(error.localizedDescription)
        }
    }

    func restorePurchases() async {
        do {
            try await subscriptionInteractor.restorePurchases()
        } catch {
            self.error = .purchaseFailed(error.localizedDescription)
        }
    }
}
