//
//  CartioShortcuts.swift
//  Cartio
//

import AppIntents

struct CartioShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ShareCardIntent(),
            phrases: [
                "Share my business card with \(.applicationName)",
                "Share my card with \(.applicationName)"
            ],
            shortTitle: "Share Card",
            systemImageName: "square.and.arrow.up"
        )
        AppShortcut(
            intent: ShowQRCodeIntent(),
            phrases: [
                "Show my QR code with \(.applicationName)",
                "Show my QR code in \(.applicationName)"
            ],
            shortTitle: "Show QR Code",
            systemImageName: "qrcode"
        )
    }
}
