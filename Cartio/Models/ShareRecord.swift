//
//  ShareRecord.swift
//  Cartio
//

import Foundation
import SwiftData

@Model
final class ShareRecord {

    @Attribute(.unique) var id: UUID
    var cardID: UUID
    var method: ShareMethod
    var timestamp: Date

    init(
        id: UUID = UUID(),
        cardID: UUID,
        method: ShareMethod,
        timestamp: Date = .now
    ) {
        self.id = id
        self.cardID = cardID
        self.method = method
        self.timestamp = timestamp
    }
}

// MARK: - Share Method

enum ShareMethod: String, Codable, CaseIterable {
    case qrCode = "qr"
    case nfc = "nfc"
    case link = "link"
    case wallet = "wallet"
    case airdrop = "airdrop"
    case email = "email"
    case emailSignature = "email_signature"
    case sms = "sms"

    var displayName: String {
        switch self {
        case .qrCode: return "QR Code"
        case .nfc: return "NFC"
        case .link: return "Link"
        case .wallet: return "Wallet"
        case .airdrop: return "AirDrop"
        case .email: return "Email"
        case .emailSignature: return "Email Signature"
        case .sms: return "SMS"
        }
    }

    var iconName: String {
        switch self {
        case .qrCode: return "qrcode"
        case .nfc: return "wave.3.right"
        case .link: return "link"
        case .wallet: return "wallet.pass"
        case .airdrop: return "airdrop"
        case .email: return "envelope"
        case .emailSignature: return "signature"
        case .sms: return "message"
        }
    }
}
