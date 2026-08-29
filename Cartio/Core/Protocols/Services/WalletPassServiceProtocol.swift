//
//  WalletPassServiceProtocol.swift
//  Cartio
//

import Foundation

@MainActor
protocol WalletPassServiceProtocol {
    func generatePass(for card: BusinessCard) async throws -> Data
    func isWalletAvailable() -> Bool
}
