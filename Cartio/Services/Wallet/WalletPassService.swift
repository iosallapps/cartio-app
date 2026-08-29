//
//  WalletPassService.swift
//  Cartio
//
//  Deferred to Sprint 4 — requires server-side signing.
//  Stub implementation for now.
//

import Foundation

final class WalletPassService: WalletPassServiceProtocol {

    func generatePass(for card: BusinessCard) async throws -> Data {
        // TODO: Call Cloud Function to generate .pkpass server-side
        // The function signs with Apple pass certificate and returns base64 data
        throw CartioError.walletPassFailed
    }

    func isWalletAvailable() -> Bool {
        // TODO: Check PKPassLibrary.isPassLibraryAvailable()
        return false
    }
}
