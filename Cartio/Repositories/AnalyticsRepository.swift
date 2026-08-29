//
//  AnalyticsRepository.swift
//  Cartio
//

import Foundation
import SwiftData
import os

final class AnalyticsRepository: AnalyticsRepositoryProtocol {

    private let modelContext: ModelContext
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Cartio", category: "AnalyticsRepository")

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func recordEvent(cardID: UUID, type: CardEventType, metadata: [String: String]) async {
        let event = CardEvent(cardID: cardID, type: type, metadata: metadata)
        modelContext.insert(event)
        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to save analytics event for card \(cardID): \(error.localizedDescription)")
        }
    }

    func fetchEvents(for cardID: UUID, type: CardEventType?, since: Date) async throws -> [CardEvent] {
        if let type {
            let typeRaw = type.rawValue
            let descriptor = FetchDescriptor<CardEvent>(
                predicate: #Predicate { $0.cardID == cardID && $0.type.rawValue == typeRaw && $0.timestamp >= since },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            return try modelContext.fetch(descriptor)
        } else {
            let descriptor = FetchDescriptor<CardEvent>(
                predicate: #Predicate { $0.cardID == cardID && $0.timestamp >= since },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            return try modelContext.fetch(descriptor)
        }
    }

    func fetchAllEvents(since: Date) async throws -> [CardEvent] {
        let descriptor = FetchDescriptor<CardEvent>(
            predicate: #Predicate { $0.timestamp >= since },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func shareRecords(for cardID: UUID, since: Date) async throws -> [ShareRecord] {
        let descriptor = FetchDescriptor<ShareRecord>(
            predicate: #Predicate { $0.cardID == cardID && $0.timestamp >= since },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func allShareRecords(since: Date) async throws -> [ShareRecord] {
        let descriptor = FetchDescriptor<ShareRecord>(
            predicate: #Predicate { $0.timestamp >= since },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
}
