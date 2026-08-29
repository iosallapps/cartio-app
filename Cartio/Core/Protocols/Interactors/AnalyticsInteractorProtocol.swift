//
//  AnalyticsInteractorProtocol.swift
//  Cartio
//

import Foundation

@MainActor
protocol AnalyticsInteractorProtocol {
    func recordEvent(cardID: UUID, type: CardEventType, metadata: [String: String]) async
    func summary(for cardID: UUID, period: AnalyticsPeriod) async throws -> AnalyticsSummary
    func aggregateSummary(period: AnalyticsPeriod) async throws -> AnalyticsSummary
    func shareMethodBreakdown(for cardID: UUID?, period: AnalyticsPeriod) async throws -> [ShareMethod: Int]
}

enum AnalyticsPeriod: String, CaseIterable {
    case sevenDays = "7d"
    case thirtyDays = "30d"
    case ninetyDays = "90d"
    case allTime = "All"

    var startDate: Date {
        switch self {
        case .sevenDays: return Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
        case .thirtyDays: return Calendar.current.date(byAdding: .day, value: -30, to: .now) ?? .now
        case .ninetyDays: return Calendar.current.date(byAdding: .day, value: -90, to: .now) ?? .now
        case .allTime: return .distantPast
        }
    }
}
