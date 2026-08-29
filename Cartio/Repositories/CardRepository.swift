//
//  CardRepository.swift
//  Cartio
//

import Foundation
import SwiftData

final class CardRepository: CardRepositoryProtocol {

    private let modelContext: ModelContext
    private let firestoreService: FirestoreService
    private let syncService: SyncServiceProtocol

    init(modelContext: ModelContext, firestoreService: FirestoreService, syncService: SyncServiceProtocol) {
        self.modelContext = modelContext
        self.firestoreService = firestoreService
        self.syncService = syncService
    }

    func fetchAll() async throws -> [BusinessCard] {
        let descriptor = FetchDescriptor<BusinessCard>(
            predicate: #Predicate { !$0.isArchived },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetch(id: UUID) async throws -> BusinessCard? {
        let descriptor = FetchDescriptor<BusinessCard>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    func save(_ card: BusinessCard) async throws {
        card.updatedAt = .now
        if card.modelContext == nil {
            modelContext.insert(card)
        }
        try modelContext.save()

        // TODO: Sync to Firestore (queue if offline)
    }

    func delete(_ card: BusinessCard) async throws {
        modelContext.delete(card)
        try modelContext.save()

        // TODO: Sync deletion to Firestore
    }

    func setDefault(_ card: BusinessCard) async throws {
        // Unset all other defaults
        let allCards = try await fetchAll()
        for existing in allCards {
            existing.isDefault = false
        }

        card.isDefault = true
        card.updatedAt = .now
        try modelContext.save()
    }
}
