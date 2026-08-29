//
//  ShareHubViewModel.swift
//  Cartio
//

import UIKit
import SwiftUI

@Observable
final class ShareHubViewModel {

    var selectedCard: BusinessCard?
    var qrImage: UIImage?
    var shareURL: URL?
    var recentShares: [ShareRecord] = []
    var isWritingNFC = false
    var error: CartioError?
    var qrColorHex: String = "#000000"
    var showNFCWrite = false
    var showSignature = false
    var showPaywall = false
    var toastMessage: String?

    private let shareInteractor: ShareInteractorProtocol
    private let cardInteractor: CardInteractorProtocol
    private let subscriptionInteractor: SubscriptionInteractorProtocol?

    var canAccessNFC: Bool { subscriptionInteractor?.canAccess(.nfcWrite) ?? false }
    var canAccessSignature: Bool { subscriptionInteractor?.canAccess(.emailSignature) ?? false }
    var canCustomizeQR: Bool { subscriptionInteractor?.canAccess(.customQRColors) ?? false }

    init(
        shareInteractor: ShareInteractorProtocol,
        cardInteractor: CardInteractorProtocol,
        subscriptionInteractor: SubscriptionInteractorProtocol? = nil
    ) {
        self.shareInteractor = shareInteractor
        self.cardInteractor = cardInteractor
        self.subscriptionInteractor = subscriptionInteractor
        self.qrColorHex = UserDefaults.standard.string(forKey: "qrColorHex") ?? "#000000"
    }

    func loadDefaultCard(context: Any? = nil) async {
        do {
            let cards = try await cardInteractor.fetchCards()
            selectedCard = cards.first(where: { $0.isDefault }) ?? cards.first
            if let card = selectedCard {
                generateQR(for: card)
                await loadRecentShares(for: card.id)
            }
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    func generateQR(for card: BusinessCard) {
        let color = UIColor(Color(hex: qrColorHex))
        let qrSize = CGSize(width: 300, height: 300)
        qrImage = shareInteractor.generateQRCode(for: card, size: qrSize, foregroundColor: color)
        shareURL = shareInteractor.getShareURL(for: card)
    }

    func updateQRColor(_ hex: String) {
        qrColorHex = hex
        UserDefaults.standard.set(hex, forKey: "qrColorHex")
        if let card = selectedCard {
            generateQR(for: card)
        }
    }

    func copyLinkToClipboard() {
        guard let card = selectedCard else { return }
        let url = shareInteractor.getShareURL(for: card)
        UIPasteboard.general.string = url.absoluteString
        Task { [weak self] in await self?.shareInteractor.recordShare(cardID: card.id, method: .link) }
    }

    func generateEmailSignature(for card: BusinessCard) -> String {
        shareInteractor.generateEmailSignature(for: card)
    }

    func recordShareMethod(_ method: ShareMethod, for card: BusinessCard) async {
        await shareInteractor.recordShare(cardID: card.id, method: method)
        await loadRecentShares(for: card.id)
    }

    func loadRecentShares(for cardID: UUID) async {
        recentShares = (try? await shareInteractor.recentShares(for: cardID)) ?? []
    }

    func showToast(_ message: String) {
        Haptics.success()
        toastMessage = message
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            toastMessage = nil
        }
    }
}
