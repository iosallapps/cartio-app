//
//  DependencyContainer.swift
//  Cartio
//

import Foundation
import SwiftData

/// Wires all protocol → concrete bindings at app launch.
/// The only singleton in the app.
@MainActor
final class DependencyContainer {
    static let shared = DependencyContainer()

    // MARK: - Services

    lazy var authService: AuthServiceProtocol = AuthService()
    lazy var qrCodeService: QRCodeServiceProtocol = QRCodeService()
    lazy var nfcService: NFCServiceProtocol = NFCService()
    lazy var walletPassService: WalletPassServiceProtocol = WalletPassService()
    lazy var cardScannerService: CardScannerServiceProtocol = CardScannerService()
    lazy var appleContactsService: AppleContactsServiceProtocol = AppleContactsService()
    lazy var subscriptionService: SubscriptionServiceProtocol = SubscriptionService()
    lazy var syncService: SyncServiceProtocol = SyncService()
    lazy var firestoreService: FirestoreService = FirestoreService()
    lazy var contactExportService: ContactExportServiceProtocol = ContactExportService()
    let emailSignatureGenerator = EmailSignatureGenerator()

    // MARK: - Repositories

    func makeCardRepository(modelContext: ModelContext) -> CardRepositoryProtocol {
        CardRepository(modelContext: modelContext, firestoreService: firestoreService, syncService: syncService)
    }

    func makeContactRepository(modelContext: ModelContext) -> ContactRepositoryProtocol {
        ContactRepository(modelContext: modelContext)
    }

    func makeUserRepository() -> UserRepositoryProtocol {
        UserRepository(authService: authService, firestoreService: firestoreService)
    }

    func makeAnalyticsRepository(modelContext: ModelContext) -> AnalyticsRepositoryProtocol {
        AnalyticsRepository(modelContext: modelContext)
    }

    // MARK: - Interactors

    func makeCardInteractor(modelContext: ModelContext) -> CardInteractorProtocol {
        CardInteractor(
            repository: makeCardRepository(modelContext: modelContext),
            subscriptionInteractor: makeSubscriptionInteractor()
        )
    }

    func makeContactInteractor(modelContext: ModelContext) -> ContactInteractorProtocol {
        ContactInteractor(
            repository: makeContactRepository(modelContext: modelContext),
            appleContactsService: appleContactsService
        )
    }

    func makeShareInteractor(modelContext: ModelContext) -> ShareInteractorProtocol {
        ShareInteractor(
            qrCodeService: qrCodeService,
            nfcService: nfcService,
            modelContext: modelContext
        )
    }

    func makeSubscriptionInteractor() -> SubscriptionInteractorProtocol {
        SubscriptionInteractor(subscriptionService: subscriptionService)
    }

    func makeAnalyticsInteractor(modelContext: ModelContext) -> AnalyticsInteractorProtocol {
        AnalyticsInteractor(repository: makeAnalyticsRepository(modelContext: modelContext))
    }

    // MARK: - ViewModels

    func makeOnboardingViewModel(modelContext: ModelContext) -> OnboardingViewModel {
        OnboardingViewModel(
            cardInteractor: makeCardInteractor(modelContext: modelContext),
            subscriptionInteractor: makeSubscriptionInteractor()
        )
    }

    func makeCardsViewModel(modelContext: ModelContext) -> CardsViewModel {
        CardsViewModel(cardInteractor: makeCardInteractor(modelContext: modelContext))
    }

    func makeCardEditorViewModel(modelContext: ModelContext, card: BusinessCard? = nil) -> CardEditorViewModel {
        CardEditorViewModel(
            cardInteractor: makeCardInteractor(modelContext: modelContext),
            existingCard: card
        )
    }

    func makeShareHubViewModel(modelContext: ModelContext) -> ShareHubViewModel {
        ShareHubViewModel(
            shareInteractor: makeShareInteractor(modelContext: modelContext),
            cardInteractor: makeCardInteractor(modelContext: modelContext),
            subscriptionInteractor: makeSubscriptionInteractor()
        )
    }

    func makeContactsViewModel(modelContext: ModelContext) -> ContactsViewModel {
        ContactsViewModel(contactInteractor: makeContactInteractor(modelContext: modelContext))
    }

    func makeCardScannerViewModel(modelContext: ModelContext) -> CardScannerViewModel {
        CardScannerViewModel(
            scannerService: cardScannerService,
            contactInteractor: makeContactInteractor(modelContext: modelContext)
        )
    }

    func makeProfileViewModel(modelContext: ModelContext) -> ProfileViewModel {
        ProfileViewModel(
            userRepository: makeUserRepository(),
            subscriptionInteractor: makeSubscriptionInteractor(),
            cardInteractor: makeCardInteractor(modelContext: modelContext),
            contactInteractor: makeContactInteractor(modelContext: modelContext),
            analyticsInteractor: makeAnalyticsInteractor(modelContext: modelContext)
        )
    }

    private init() {}
}
