//
//  ShareInteractor.swift
//  Cartio
//

import UIKit
import SwiftData
import os

final class ShareInteractor: ShareInteractorProtocol {

    private let qrCodeService: QRCodeServiceProtocol
    private let nfcService: NFCServiceProtocol
    private let modelContext: ModelContext
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Cartio", category: "ShareInteractor")

    init(qrCodeService: QRCodeServiceProtocol, nfcService: NFCServiceProtocol, modelContext: ModelContext) {
        self.qrCodeService = qrCodeService
        self.nfcService = nfcService
        self.modelContext = modelContext
    }

    func generateQRCode(for card: BusinessCard, size: CGSize, foregroundColor: UIColor) -> UIImage? {
        let url = getShareURL(for: card).absoluteString
        return qrCodeService.generate(from: url, size: size, foregroundColor: foregroundColor)
    }

    private static let fallbackURL: URL = {
        guard let url = URL(string: AppConstants.URLs.baseURL) else {
            // baseURL is a compile-time constant; this should never fail.
            return URL(string: "https://cartio.app")!
        }
        return url
    }()

    func getShareURL(for card: BusinessCard) -> URL {
        // TODO: Use actual username from user profile
        let username = card.name.lowercased().replacingOccurrences(of: " ", with: "")
        guard let url = URL(string: "\(AppConstants.URLs.baseURL)/\(username)") else {
            return Self.fallbackURL
        }
        return url
    }

    func generateEmailSignature(for card: BusinessCard) -> String {
        """
        <table cellpadding="0" cellspacing="0" style="font-family: -apple-system, BlinkMacSystemFont, sans-serif;">
          <tr><td style="font-size: 16px; font-weight: bold; color: #1A1A1A;">\(card.name)</td></tr>
          <tr><td style="font-size: 13px; color: #6B7280;">\
        \(card.title)\(card.company.isEmpty ? "" : " at \(card.company)")</td></tr>
          <tr><td style="padding-top: 8px; font-size: 13px; color: #0A7E8C;">\
        \(card.phone) | \(card.email)</td></tr>
          <tr><td style="padding-top: 4px;"><a href="\(getShareURL(for: card))" \
        style="font-size: 12px; color: #0A7E8C;">View my digital card</a></td></tr>
        </table>
        """
    }

    func recordShare(cardID: UUID, method: ShareMethod) async {
        let record = ShareRecord(cardID: cardID, method: method)
        modelContext.insert(record)

        // Also record as CardEvent for analytics
        let event = CardEvent(cardID: cardID, type: .share, metadata: ["method": method.rawValue])
        modelContext.insert(event)

        do {
            try modelContext.save()
        } catch {
            logger.error(
                "Failed to save share record for card \(cardID), method \(method.rawValue): \(error)"
            )
        }
    }

    func recentShares(for cardID: UUID) async throws -> [ShareRecord] {
        let descriptor = FetchDescriptor<ShareRecord>(
            predicate: #Predicate { $0.cardID == cardID },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return Array(try modelContext.fetch(descriptor).prefix(5))
    }
}
