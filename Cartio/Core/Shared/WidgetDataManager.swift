//
//  WidgetDataManager.swift
//  Cartio
//
//  Shared helper for reading/writing default card data
//  to the App Group container used by both the main app
//  and the CartioWidget extension.
//

import Foundation
import WidgetKit

/// Lightweight struct representing the card data the widget needs.
/// Shared between main app and widget extension via App Group UserDefaults.
struct WidgetCardData: Codable {
    let name: String
    let title: String
    let company: String
    let shareURL: String
    let qrColorHex: String

    init(name: String, title: String, company: String, shareURL: String, qrColorHex: String = "#000000") {
        self.name = name
        self.title = title
        self.company = company
        self.shareURL = shareURL
        self.qrColorHex = qrColorHex
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        title = try container.decode(String.self, forKey: .title)
        company = try container.decode(String.self, forKey: .company)
        shareURL = try container.decode(String.self, forKey: .shareURL)
        qrColorHex = try container.decodeIfPresent(String.self, forKey: .qrColorHex) ?? "#000000"
    }
}

enum WidgetDataManager {

    private static let suiteName = AppConstants.appGroupID
    private static let cardKey = "widgetDefaultCard"

    // MARK: - Write (main app)

    static func saveDefaultCard(_ data: WidgetCardData) {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return }
        let encoded = try? JSONEncoder().encode(data)
        defaults.set(encoded, forKey: cardKey)
        WidgetCenter.shared.reloadAllTimelines()
    }

    static func saveDefaultCard(from card: BusinessCard) {
        let username = card.name.lowercased().replacingOccurrences(of: " ", with: "")
        let url = "\(AppConstants.URLs.baseURL)/\(username)"
        let qrColor = UserDefaults.standard.string(forKey: "qrColorHex") ?? "#000000"
        let data = WidgetCardData(
            name: card.name,
            title: card.title,
            company: card.company,
            shareURL: url,
            qrColorHex: qrColor
        )
        saveDefaultCard(data)
    }

    // MARK: - Read (widget extension)

    static func loadDefaultCard() -> WidgetCardData? {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = defaults.data(forKey: cardKey) else { return nil }
        return try? JSONDecoder().decode(WidgetCardData.self, from: data)
    }

    // MARK: - Clear

    static func clear() {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return }
        defaults.removeObject(forKey: cardKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
