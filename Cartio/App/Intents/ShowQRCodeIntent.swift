//
//  ShowQRCodeIntent.swift
//  Cartio
//

import AppIntents

struct ShowQRCodeIntent: AppIntent {
    static var title: LocalizedStringResource = "Show My QR Code"
    static var description: IntentDescription = "Opens Cartio to display your QR code fullscreen"
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        UserDefaults.standard.set("cartio://qr-fullscreen", forKey: "pendingDeepLink")
        return .result()
    }
}
