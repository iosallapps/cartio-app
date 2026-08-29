//
//  ShareInteractorProtocol.swift
//  Cartio
//

import UIKit

@MainActor
protocol ShareInteractorProtocol {
    func generateQRCode(for card: BusinessCard, size: CGSize, foregroundColor: UIColor) -> UIImage?
    func getShareURL(for card: BusinessCard) -> URL
    func generateEmailSignature(for card: BusinessCard) -> String
    func recordShare(cardID: UUID, method: ShareMethod) async
    func recentShares(for cardID: UUID) async throws -> [ShareRecord]
}
