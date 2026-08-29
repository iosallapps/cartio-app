//
//  CartioError.swift
//  Cartio
//

import Foundation

enum CartioError: LocalizedError {
    // Auth
    case authFailed(String)
    case notAuthenticated

    // Cards
    case cardLimitReached
    case cardNotFound
    case cardSaveFailed

    // Contacts
    case contactNotFound
    case duplicateContact
    case contactsPermissionDenied

    // Sharing
    case qrGenerationFailed
    case nfcNotAvailable
    case nfcWriteFailed
    case walletPassFailed
    case shareLinkFailed

    // Scanner
    case cameraPermissionDenied
    case ocrFailed
    case scanLimitReached

    // Subscription
    case purchaseFailed(String)
    case productNotFound
    case featureRequiresPremium

    // Sync
    case syncFailed(String)
    case offlineOperationQueued
    case conflictResolutionFailed

    // Export
    case exportFailed(String)

    // Generic
    case networkError(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .authFailed(let message): return "Authentication failed: \(message)"
        case .notAuthenticated: return "Please sign in to continue."
        case .cardLimitReached: return "Free plan allows up to \(AppConstants.FreeTier.maxCards) cards. Upgrade to Pro for unlimited cards."
        case .cardNotFound: return "Card not found."
        case .cardSaveFailed: return "Failed to save card. Please try again."
        case .contactNotFound: return "Contact not found."
        case .duplicateContact: return "This contact already exists."
        case .contactsPermissionDenied: return "Please allow access to Contacts in Settings."
        case .qrGenerationFailed: return "Failed to generate QR code."
        case .nfcNotAvailable: return "NFC is not available on this device."
        case .nfcWriteFailed: return "Failed to write NFC tag. Please try again."
        case .walletPassFailed: return "Failed to create Wallet pass."
        case .shareLinkFailed: return "Failed to generate share link."
        case .cameraPermissionDenied: return "Please allow camera access in Settings to scan cards."
        case .ocrFailed: return "Failed to scan card. Please try again or enter details manually."
        case .scanLimitReached: return "Free plan allows \(AppConstants.FreeTier.maxOCRScansPerMonth) scans per month. Upgrade to Pro for unlimited scans."
        case .purchaseFailed(let message): return "Purchase failed: \(message)"
        case .productNotFound: return "Subscription product not found."
        case .featureRequiresPremium: return "This feature requires a Pro subscription."
        case .syncFailed(let message): return "Sync failed: \(message)"
        case .offlineOperationQueued: return "You're offline. Changes will sync when connected."
        case .conflictResolutionFailed: return "Failed to resolve sync conflict."
        case .exportFailed(let message): return "Export failed: \(message)"
        case .networkError(let message): return "Network error: \(message)"
        case .unknown(let message): return "Something went wrong: \(message)"
        }
    }
}
