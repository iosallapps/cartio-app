//
//  MockCardRepository.swift
//  CartioTests
//

import Foundation
@testable import Cartio

@MainActor
final class MockCardRepository: CardRepositoryProtocol {

    var cards: [BusinessCard] = []
    var shouldThrow = false

    func fetchAll() async throws -> [BusinessCard] {
        if shouldThrow { throw CartioError.unknown("mock error") }
        return cards
    }

    func fetch(id: UUID) async throws -> BusinessCard? {
        cards.first(where: { $0.id == id })
    }

    func save(_ card: BusinessCard) async throws {
        if shouldThrow { throw CartioError.cardSaveFailed }
        if let idx = cards.firstIndex(where: { $0.id == card.id }) {
            cards[idx] = card
        } else {
            cards.append(card)
        }
    }

    func delete(_ card: BusinessCard) async throws {
        if shouldThrow { throw CartioError.unknown("mock error") }
        cards.removeAll(where: { $0.id == card.id })
    }

    func setDefault(_ card: BusinessCard) async throws {
        if shouldThrow { throw CartioError.unknown("mock error") }
        for c in cards { c.isDefault = false }
        card.isDefault = true
    }
}
