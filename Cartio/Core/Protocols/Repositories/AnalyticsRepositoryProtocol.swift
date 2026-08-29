//
//  AnalyticsRepositoryProtocol.swift
//  Cartio
//

import Foundation

@MainActor
protocol AnalyticsRepositoryProtocol {
    func recordEvent(cardID: UUID, type: CardEventType, metadata: [String: String]) async
    func fetchEvents(for cardID: UUID, type: CardEventType?, since: Date) async throws -> [CardEvent]
    func fetchAllEvents(since: Date) async throws -> [CardEvent]
    func shareRecords(for cardID: UUID, since: Date) async throws -> [ShareRecord]
    func allShareRecords(since: Date) async throws -> [ShareRecord]
}
