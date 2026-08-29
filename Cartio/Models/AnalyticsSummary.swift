//
//  AnalyticsSummary.swift
//  Cartio
//
//  Plain struct — not persisted in SwiftData.
//  Represents aggregated analytics data for a card.
//

import Foundation

struct AnalyticsSummary {
    let totalViews: Int
    let totalSaves: Int
    let totalShares: Int
    let conversionRate: Double
    let viewsByDay: [Date: Int]
    let topLinks: [String: Int]
    let deviceBreakdown: [String: Int]
    let periodStart: Date
    let periodEnd: Date

    var isEmpty: Bool {
        totalViews == 0 && totalSaves == 0 && totalShares == 0
    }

    static let empty = AnalyticsSummary(
        totalViews: 0,
        totalSaves: 0,
        totalShares: 0,
        conversionRate: 0,
        viewsByDay: [:],
        topLinks: [:],
        deviceBreakdown: [:],
        periodStart: .now,
        periodEnd: .now
    )
}
