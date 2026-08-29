//
//  ProfileViewModel.swift
//  Cartio
//
//  Consolidated: handles profile + analytics + settings + subscription.
//

import Foundation
import StoreKit
import UIKit

@Observable
final class ProfileViewModel {

    var userProfile: UserProfile?
    var analytics: AnalyticsSummary?
    var cardCount = 0
    var contactCount = 0
    var shareCount = 0
    var products: [Product] = []
    var isPremium = false
    var isLoading = false
    var showSubscription = false
    var showDeleteConfirmation = false
    var selectedAppearance = 0
    var error: CartioError?

    var displayName: String { userProfile?.displayName ?? "User" }
    var email: String { userProfile?.email ?? "" }
    var planBadge: String { isPremium ? "Pro" : "Free" }
    var userInitials: String {
        displayName.split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
            .uppercased()
    }

    private let userRepository: UserRepositoryProtocol
    private let subscriptionInteractor: SubscriptionInteractorProtocol
    private let cardInteractor: CardInteractorProtocol
    private let contactInteractor: ContactInteractorProtocol
    private let analyticsInteractor: AnalyticsInteractorProtocol?

    init(
        userRepository: UserRepositoryProtocol,
        subscriptionInteractor: SubscriptionInteractorProtocol,
        cardInteractor: CardInteractorProtocol,
        contactInteractor: ContactInteractorProtocol,
        analyticsInteractor: AnalyticsInteractorProtocol? = nil
    ) {
        self.userRepository = userRepository
        self.subscriptionInteractor = subscriptionInteractor
        self.cardInteractor = cardInteractor
        self.contactInteractor = contactInteractor
        self.analyticsInteractor = analyticsInteractor
    }

    func loadProfile() async {
        isLoading = true
        defer { isLoading = false }

        isPremium = subscriptionInteractor.isPremium

        do {
            userProfile = try await userRepository.getCurrentUser()
            let cards = try await cardInteractor.fetchCards()
            cardCount = cards.count
            contactCount = (try? await contactInteractor.fetchContacts(filter: nil))?.count ?? 0
            shareCount = (try? await analyticsInteractor?.aggregateSummary(period: .allTime))?.totalShares ?? 0
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    func loadAnalytics(period: AnalyticsPeriod = .thirtyDays) async {
        analytics = try? await analyticsInteractor?.aggregateSummary(period: period)
    }

    func loadProducts() async {
        do {
            products = try await subscriptionInteractor.fetchProducts()
        } catch {
            self.error = .productNotFound
        }
    }

    func purchase(_ product: Product) async {
        do {
            try await subscriptionInteractor.purchase(product)
            isPremium = subscriptionInteractor.isPremium
        } catch let err as CartioError {
            error = err
        } catch {
            self.error = .purchaseFailed(error.localizedDescription)
        }
    }

    func restorePurchases() async {
        do {
            try await subscriptionInteractor.restorePurchases()
            isPremium = subscriptionInteractor.isPremium
        } catch {
            self.error = .purchaseFailed(error.localizedDescription)
        }
    }

    func signOut(router: AppRouter) {
        // Clear premium cache
        UserDefaults.standard.removeObject(forKey: "cartio_is_premium_cached")
        router.signOut()
    }

    func fetchProducts() async {
        await loadProducts()
    }

    func deleteAccount() async {
        do {
            try await userRepository.deleteAccount()
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    func applyAppearance() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        switch selectedAppearance {
        case 1: window.overrideUserInterfaceStyle = .light
        case 2: window.overrideUserInterfaceStyle = .dark
        default: window.overrideUserInterfaceStyle = .unspecified
        }
    }
}
