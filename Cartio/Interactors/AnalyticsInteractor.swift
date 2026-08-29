//
//  AnalyticsInteractor.swift
//  Cartio
//

import Foundation

final class AnalyticsInteractor: AnalyticsInteractorProtocol {

    private let repository: AnalyticsRepositoryProtocol

    init(repository: AnalyticsRepositoryProtocol) {
        self.repository = repository
    }

    func recordEvent(cardID: UUID, type: CardEventType, metadata: [String: String]) async {
        await repository.recordEvent(cardID: cardID, type: type, metadata: metadata)
    }

    func summary(for cardID: UUID, period: AnalyticsPeriod) async throws -> AnalyticsSummary {
        let since = period.startDate
        let events = try await repository.fetchEvents(for: cardID, type: nil, since: since)
        let shares = try await repository.shareRecords(for: cardID, since: since)
        return buildSummary(from: events, shares: shares, since: since)
    }

    func aggregateSummary(period: AnalyticsPeriod) async throws -> AnalyticsSummary {
        let since = period.startDate
        let events = try await repository.fetchAllEvents(since: since)
        let shares = try await repository.allShareRecords(since: since)
        return buildSummary(from: events, shares: shares, since: since)
    }

    func shareMethodBreakdown(for cardID: UUID?, period: AnalyticsPeriod) async throws -> [ShareMethod: Int] {
        let since = period.startDate
        let shares: [ShareRecord]
        if let cardID {
            shares = try await repository.shareRecords(for: cardID, since: since)
        } else {
            shares = try await repository.allShareRecords(since: since)
        }

        var breakdown: [ShareMethod: Int] = [:]
        for share in shares {
            breakdown[share.method, default: 0] += 1
        }
        return breakdown
    }

    // MARK: - Private

    private func buildSummary(from events: [CardEvent], shares: [ShareRecord], since: Date) -> AnalyticsSummary {
        let calendar = Calendar.current

        let totalViews = events.filter { $0.type == .view }.count
        let totalSaves = events.filter { $0.type == .save }.count
        let totalShares = shares.count
        let conversionRate = totalViews > 0 ? Double(totalSaves) / Double(totalViews) : 0

        // Group views by day
        var viewsByDay: [Date: Int] = [:]
        for event in events where event.type == .view {
            let day = calendar.startOfDay(for: event.timestamp)
            viewsByDay[day, default: 0] += 1
        }

        // Top links from linkTap events
        var topLinks: [String: Int] = [:]
        for event in events where event.type == .linkTap {
            if let link = event.metadata["link"] {
                topLinks[link, default: 0] += 1
            }
        }

        // Device breakdown from view metadata
        var devices: [String: Int] = [:]
        for event in events where event.type == .view {
            let device = event.metadata["device"] ?? "Unknown"
            devices[device, default: 0] += 1
        }

        return AnalyticsSummary(
            totalViews: totalViews,
            totalSaves: totalSaves,
            totalShares: totalShares,
            conversionRate: conversionRate,
            viewsByDay: viewsByDay,
            topLinks: topLinks,
            deviceBreakdown: devices,
            periodStart: since,
            periodEnd: .now
        )
    }
}
