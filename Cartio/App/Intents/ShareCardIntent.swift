//
//  ShareCardIntent.swift
//  Cartio
//

import AppIntents

struct ShareCardIntent: AppIntent {
    static var title: LocalizedStringResource = "Share My Business Card"
    static var description: IntentDescription = "Opens Cartio to share your business card"
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        UserDefaults.standard.set("cartio://share", forKey: "pendingDeepLink")
        return .result()
    }
}
